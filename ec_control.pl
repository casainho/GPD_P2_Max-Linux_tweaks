#!/usr/bin/perl -w

# Copyright (C) 2007  Michael Kurz     michi.kurz (at) googlemail.com
# Copyright (C) 2007  Petr Tomasek     tomasek (#) etf,cuni,cz
# Copyright (C) 2007  Carlos Corbacho  cathectic (at) gmail.com
#
# Version 0.6.1 (2007-11-08)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


my $TEMPERATURE_FAN_DISABLE = 55;
my $TEMPERATURE_FAN_LEVEL_1 = 58;
my $TEMPERATURE_FAN_LEVEL_2 = 61;
my $TEMPERATURE_FAN_LEVEL_3 = 64;
my $TEMPERATURE_FAN_LEVEL_4 = 67;

my $FAN_DISABLE = 0xf1;
my $FAN_LEVEL_1 = 0xf8;
my $FAN_LEVEL_2 = 0xff;
my $FAN_LEVEL_3 = 0xfa;
my $FAN_LEVEL_4 = 0xfb;

require 5.004;

use strict;
use Fcntl;
use POSIX;
use File::Basename;

sub initialize_ioports
{
  sysopen (IOPORTS, "/dev/port", O_RDWR)
    or die "/dev/port: $!\n";
  binmode IOPORTS;
}

sub close_ioports
{
  close (IOPORTS)
    or print "Warning: $!\n";
}



sub inb
{
  my ($res,$nrchars);
  sysseek IOPORTS, $_[0], 0 or return -1;
  $nrchars = sysread IOPORTS, $res, 1;
  return -1 if not defined $nrchars or $nrchars != 1;
  $res = unpack "C",$res ;
  return $res;
}

# $_[0]: value to write
# $_[1]: port to write
# Returns: -1 on failure, 0 on success.
sub outb
{
  if ($_[0] > 0xff)
  {
    my ($package, $filename, $line, $sub) = caller(1);
    print "\n*** Called outb with value=$_[1] from line $line\n",
          "*** (in $sub). PLEASE REPORT!\n",
          "*** Terminating.\n";
    exit(-1);
  }
  my $towrite = pack "C", $_[0];
  sysseek IOPORTS, $_[1], 0 or return -1;
  my $nrchars = syswrite IOPORTS, $towrite, 1;
  return -1 if not defined $nrchars or $nrchars != 1;
  return 0;
}

sub wait_write
{
	my $i = 0;
	while ((inb($_[0]) & 0x02) && ($i < 10000)) {
		sleep(0.01);
		$i++;
	}
	return -($i == 10000);
}

sub wait_read
{
	my $i = 0;
	while (!(inb($_[0]) & 0x01) && ($i < 10000)) {
		sleep(0.01);
		$i++;
	}
	return -($i == 10000);
}

sub wait_write_ec
{
	wait_write(0x66);
}

sub wait_read_ec
{
	wait_read(0x66);
}

sub send_ec
{
	if (!wait_write_ec()) { outb($_[0], 0x66); }
	if (!wait_write_ec()) { outb($_[1], 0x62); }
}

sub write_ec
{
	if (!wait_write_ec()) { outb(0x81, 0x66 ); }
	if (!wait_write_ec()) { outb($_[0], 0x62); }
	if (!wait_write_ec()) { outb($_[1], 0x62); }
}

sub read_ec
{
	if (!wait_write_ec()) { outb(0x80, 0x66 ); }
	if (!wait_write_ec()) { outb($_[0], 0x62); }
	if (!wait_read_ec())  { inb(0x62); }
}

sub write_kc
{
	if (!wait_write(0x64)) { outb($_[0], 0x64); }
	if (!wait_write(0x64)) { outb($_[1], 0x60); }
}

sub print_regs
{
	initialize_ioports();

	my @arr = ("00","10","20","30","40","50","60","70","80","90","A0","B0","C0","D0","E0","F0", "");

	my $i = 0;
	my $t = 0;
	print "\n  \t00\t01\t02\t03\t04\t05\t06\t07\t|\t08\t09\t0A\t0B\t0C\t0D\t0E\t0F\n";
	print "  \t__\t__\t__\t__\t__\t__\t__\t__\t|\t__\t__\t__\t__\t__\t__\t__\t__\n";
	print "00 |\t";
	for ($i = 0; $i < 256; $i++)
	{
		$t = read_ec($i);
		print $t;
		print "\t";
		if ((($i + 1) % 8) == 0){
			if ((($i + 1) % 16) == 0) {
				if ($i != 255) { print "\n$arr[(($i-(($i + 1) % 16)) / 16) + 1] |\t"; }
			} else {
				print "|\t";
			}
		}
	}
	
	print "\n";
	
	close_ioports();
}

sub print_myregs
{
	initialize_ioports();

	my $i = 106;
	my $t = 0;
	for ($i = 106; $i < 145; $i++)
	{
		$t = read_ec($i);
		if ($i <= 112) { print "TT1:\t"; print $t; print "\n";};
		if ($i >= 114 && $i <= 120) { print "FS1:\t"; print $t; print "\n";};
		if ($i >= 130 && $i <= 136) { print "TT2:\t"; print $t; print "\n";};
		if ($i >= 138 && $i <= 144) { print "FS2:\t"; print $t; print "\n";};
	}
	
	print "\n";
	
	close_ioports();
}

sub print_myregs2
{
	initialize_ioports();
	print "\n  \tT1\tS1\tT2\tS2\n";
	print "  \t__\t__\t__\t__\n";

	my $i = 0;
	my $t = 0;
	#offsets for the beginning sequences
	my $t1 = 106; #temp section 1 = 106 to 112 inclusive (0x6A to 0x70)
	my $s1 = 114; #speed section 1 ...
	my $t2 = 130; #temp 2 ...
	my $s2 = 138; #speed 2 ...
	for ($i = 0; $i < 7; $i++)
	{
		print "Level"; print ($i+1); print "\t";
		$t = read_ec($t1 + $i); print $t; print "\t";
		$t = read_ec($s1 + $i); print $t; print "\t";
		$t = read_ec($t2 + $i); print $t; print "\t";
		$t = read_ec($s2 + $i); print $t; print "\n";
	}
	
	print "\n";
	
	close_ioports();
}

sub gpd_p2_max_write_ec
{
	if (!wait_write_ec()) { outb(0x81, 0x66 ); }
	if (!wait_write_ec()) { outb(0x31, 0x62); }
	if (!wait_write_ec()) { outb($_[0], 0x62); }
}

sub run_profile
{
	print "Values before\n";
	print_myregs2();
	my $fname = $_[0].".rw";
	my $key = "";
	my $val = "";
	my $junk = "";
	open(my $fh, "<", $fname)
		or die "Could not open file '$fname' $!";
	while (my $row = <$fh>) {
		chomp $row;
		if (index($row, '>WEC') != -1) {
			($junk, $key, $val) =  split(/ /,$row);
			write_temp(hex($key),hex($val));
		}
	}
	print "\nValues after\n";
	print_myregs2();
}

sub write_temp
{
	initialize_ioports();
	write_ec($_[0],$_[1]);
	close_ioports();
}

sub testhexnum

{
	return testnum(hex($_[0]));
}

sub testnum
{
	my $i;
	for ($i = 0; $i<256;$i++) {
		if ($_[0] eq "$i") { return 1 };
	}
	return 0;
}

my $ii;

if (!$ARGV[0]){
        print "wrong arguments!\n";
	print "usage:\n";
	print "\'acer_ec regs\' \t\t\t\tdumps all ec registers\n";
	print "\'acer_ec ledon\' \t\t\t\tswitch on 'mail LED' (WMID)\n";
	print "\'acer_ec ledoff\' \t\t\t\tswitch off 'mail LED' (WMID)\n";
	print "\'acer_ec getled\' \t\t\t\tget 'mail LED' status (WMID)\n";
	print "\'acer_ec getled2\' \t\t\t\tget 'mail LED' status(AMW0)\n";
	print "\'acer_ec getwireless\' \t\t\t\tget 'wireless' status (AMW0)\n";
	print "\'acer_ec gettouch\' \t\t\t\tis the touchpad disabled?\n";
	print "\'acer_ec setfanthresh <temp>\' \t\t\t\tset temperature threshhold to <temp>, DANGEROUS!\n";
	print "\'acer_ec getfanthresh\' \t\t\t\tget temperature threshhold\n";
	print "\'acer_ec <temp-number> <temperature>\' \tfor setting a temperature\n";
	print "where <temp-number> is from 0-7, and <temperture> is from 0-255\n";
	print "\'acer_ec ?= <reg>\' \t\tQuery register's value\n";
	print "\'acer_ec := <reg> <val>\' \tSet register's value\n";
	print "\'acer_ec +f <reg> <val>\' \tOr register's value with val (to set flags)\n";
	print "\'acer_ec -f <reg> <val>\' \tAnd register's value with ~val (to clear flags)\n";
	print "\'forcekc\' \tTry all possible values on writeable RAM of keyboard controller\n";
	print "\'kcw <cmd> <val>\' \tWrite a command and a value to the keyboard controller\n";
} elsif ($ARGV[0] eq "regs") {
	print_regs();
} elsif ($ARGV[0] eq "myregs") {
	print_myregs2();
} elsif ($ARGV[0] eq "getled") {
	# TM2490 only (WMID)
	initialize_ioports();
	if (read_ec(0x9f)&0x01) {	
		print "Mail LED on\n";
	} else {
		print "Mail LED off\n"; }
	close_ioports();
} elsif ($ARGV[0] eq "getled2") {
	# Aspire 5020 only (AMW0)
	initialize_ioports();
	if (read_ec(0x0A)&0x80) {
		print "Mail LED on\n";
	} else {
		print "Mail LED off\n"; }
	close_ioports();
} elsif ($ARGV[0] eq "getwireless") {
	# Aspire 5020 only (AMW0)
	initialize_ioports();
	if (read_ec(0x0A)&0x4) {
		print "Wireless on\n";
	} else {
		print "Wireless off\n"; }
	close_ioports();
} elsif ($ARGV[0] eq "gettouch") {
	# TM2490 only - needs testing
	initialize_ioports();
	if (read_ec(0x9e)&0x08) {
		print "touchpad disabled\n";
	} else {
		print "touchpad enabled\n"; }
	close_ioports();
} elsif ($ARGV[0] eq "?=") {
	initialize_ioports();
	my $r = hex($ARGV[1]);
	printf("%02d\n", read_ec($r));
	close_ioports();
} elsif ($ARGV[0] eq ":=") {
	initialize_ioports();
	my $r = hex($ARGV[1]);
	my $f = hex($ARGV[2]);
        write_ec( $r, $f);
	close_ioports();
} elsif ($ARGV[0] eq "+f") {
	initialize_ioports();
	my $r = hex($ARGV[1]);
	my $f = hex($ARGV[2]);
	my $val = read_ec($r);
	printf("REG[0x%02x] == 0x%02x\n", $r, $val);
	printf("REG[0x%02x] := 0x%02x\n", $r, $val | $f);
        write_ec( $r, $val | $f);
	printf("REG[0x%02x] == 0x%02x\n", $r, read_ec($r));
	close_ioports();
} elsif ($ARGV[0] eq "-f") {
	initialize_ioports();
	my $r = hex($ARGV[1]);
	my $f = hex($ARGV[2]);
	my $val = read_ec($r);
	printf("REG[0x%02x] == 0x%02x\n", $r, $val);
	printf("REG[0x%02x] := 0x%02x\n", $r, $val & ~$f);
        write_ec( $r, $val & ~$f);
	printf("REG[0x%02x] == 0x%02x\n", $r, read_ec($r));
	close_ioports();
} elsif ($ARGV[0] eq "ledon") {
	# TM2490 only - needs testing
	initialize_ioports();
	if (!wait_write(0x64)) { outb(0x59, 0x64); }
	if (!wait_write(0x64)) { outb(0x92,   0x60); }
	close_ioports();
} elsif ($ARGV[0] eq "ledoff") {
	# TM2490 only - needs testing
	initialize_ioports();
	if (!wait_write(0x64)) { outb(0x59, 0x64); }
	if (!wait_write(0x64)) { outb(0x93,   0x60); }
	close_ioports();
} elsif ($ARGV[0] eq "getfanthresh") {
	initialize_ioports();
	$ii=read_ec(0xa9);
	close_ioports();
        print "Temperature threshhold: $ii (celsius)\n";
} elsif (($ARGV[0] eq "setfanthresh") && testnum($ARGV[1])) {
	write_temp(0xA9,$ARGV[1]);
} elsif ($ARGV[0] eq "setbright") {
	# Aspire 5020 only (AMW0)
	if ($ARGV[1] >= 0 && $ARGV[1] <= 15) {
		write_temp(0x83, $ARGV[1]);
	} else {
		print "second argument must be a number between 0 and 15\n";
	}
} elsif ($ARGV[0] eq "forcekc") {
	# Be smart - we only send the commands for writing to keyboard RAM
	initialize_ioports();
	my ($kbdata, $cont, $kbreg);
	for ($kbreg = 0x40; $kbreg <= 0x5f; $kbreg++) {
		for ($kbdata = 0; $kbdata < 256; $kbdata++) {
			write_kc($kbreg, $kbdata);

			print sprintf("%0#4x", $kbreg), ", ", sprintf("%0#4x", $kbdata), "\n";
			print "Continue? y/n: ";
			$cont = <STDIN>;
			if ($cont eq "n") {
				last;
			}
		}
	}
	close_ioports();
} elsif ($ARGV[0] eq "kcw") {
	initialize_ioports();
	write_kc($ARGV[1], $ARGV[2]);
	close_ioports();
} elsif (($ARGV[0] eq "writetemp") && testnum($ARGV[1]) && testnum($ARGV[2])) {
	write_temp($ARGV[1],$ARGV[2]);
} elsif (($ARGV[0] eq "writetemphex") && testhexnum($ARGV[1]) && testhexnum($ARGV[2])) {
	write_temp(hex($ARGV[1]),hex($ARGV[2]));
} elsif ($ARGV[0] eq "setprofile") {
	run_profile($ARGV[1]);
} elsif ($ARGV[0] eq "gpd_p2_max") {
	initialize_ioports();

	my $temperature = read_ec(0x71);

	if ($temperature < $TEMPERATURE_FAN_DISABLE) {
		gpd_p2_max_write_ec($FAN_DISABLE);
	} elsif ($temperature < $TEMPERATURE_FAN_LEVEL_1) {
		gpd_p2_max_write_ec($FAN_LEVEL_1);
	} elsif ($temperature < $TEMPERATURE_FAN_LEVEL_2) {
		gpd_p2_max_write_ec($FAN_LEVEL_2);
	} elsif ($temperature < $TEMPERATURE_FAN_LEVEL_3) {
		gpd_p2_max_write_ec($FAN_LEVEL_3);
	} else {
		gpd_p2_max_write_ec($FAN_LEVEL_4);
	}

	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_0") {
	initialize_ioports();
	gpd_p2_max_write_ec($FAN_DISABLE);
	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_1") {
	initialize_ioports();
	gpd_p2_max_write_ec($FAN_LEVEL_1);
	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_2") {
	initialize_ioports();
	gpd_p2_max_write_ec($FAN_LEVEL_2);
	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_3") {
	initialize_ioports();
	gpd_p2_max_write_ec($FAN_LEVEL_3);
	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_4") {
	initialize_ioports();
	gpd_p2_max_write_ec($FAN_LEVEL_4);
	close_ioports();
} elsif ($ARGV[0] eq "gpd_p2_max-fan_value") {
	initialize_ioports();
	gpd_p2_max_write_ec($ARGV[1]);
	close_ioports();	
} else {
	print "wrong arguments!\n";
}

