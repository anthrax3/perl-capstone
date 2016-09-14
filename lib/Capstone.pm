package Capstone;

use 5.014000;
use strict;
use warnings;
require Exporter;

our $VERSION = '0.5';

our @ISA = qw(Exporter);

# Generated by :
# perl -ne 'if(m/^\s*(\S+)\s*=>\s*.+/){$h{$1}++} END{ print "qw(" . join(" ", keys %h) . ")\n"}' < lib/Capstone_const.pm

our %EXPORT_TAGS = ( 'all' =>
                     [
                       qw(CS_ARCH_SYSZ CS_MODE_V8 CS_OPT_OFF CS_OPT_SYNTAX_ATT CS_ARCH_MAX CS_MODE_MICRO CS_MODE_MIPSGP64 CS_ARCH_ARM64 CS_SUPPORT_X86_REDUCE CS_SUPPORT_DIET CS_MODE_ARM CS_MODE_16 CS_OPT_SKIPDATA_SETUP CS_OPT_DETAIL CS_OPT_ON CS_MODE_MIPS64 CS_MODE_V9 CS_ARCH_XCORE CS_OPT_SYNTAX_DEFAULT CS_OPT_SYNTAX_INTEL CS_OPT_MEM CS_ARCH_ALL CS_OPT_MODE CS_MODE_THUMB CS_OPT_SYNTAX_NOREGNAME CS_MODE_BIG_ENDIAN CS_MODE_MIPS32R6 CS_ARCH_X86 CS_OPT_SYNTAX CS_MODE_MIPS3 CS_ARCH_PPC CS_ARCH_ARM CS_ARCH_MIPS CS_MODE_32 CS_MODE_MIPS32 CS_MODE_64 CS_MODE_MCLASS CS_OPT_SKIPDATA CS_ARCH_SPARC)
                     ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

require XSLoader;
XSLoader::load('Capstone', $VERSION);


# Preloaded methods go here.

require Capstone_const;

sub new {
    my ($class, $arch, $mode) = @_;
    my $this = {};

    bless($this, $class);

    $this->{_skipdata} = 0;
    $this->{_details}  = 0;
    $this->{_handle}   = Capstone::open($arch, $mode);

    undef $this if(!defined($this->{_handle}));

    return $this;
}

sub dis {
    my ($this, $code, $address, $num) = @_;
    my @ins;
    my $details = 0;

    $num = 0 if !defined($num);
    $address = 0 if !defined($address);

    $details = 1 if($this->{_details} && !$this->{_skipdata});

    @ins =  Capstone::disasm($this->{_handle}, $code, $address, $num, $details);

    if($details) {
        foreach my $i(@ins) {

            @{ $i->{regs_read} } =
                map { Capstone::cs_reg_name($this->{_handle}, $_) } @{ $i->{regs_read} };
            @{ $i->{regs_write} } =
                map { Capstone::cs_reg_name($this->{_handle}, $_) } @{ $i->{regs_write} };
            @{ $i->{groups} } =
                map { Capstone::cs_group_name($this->{_handle}, $_) } @{ $i->{groups} };
        }
    }

    return @ins;
}

sub set_option {
    my ($this, $type, $value) = @_;
    my $ret;

    $ret = Capstone::option($this->{_handle}, $type, $value);

    if($ret) {
        $this->{_skipdata} = 1 if $type == Capstone->CS_OPT_SKIPDATA &&
            $value == Capstone->CS_OPT_ON;
        $this->{_skipdata} = 0 if $type == Capstone->CS_OPT_SKIPDATA &&
            $value == Capstone->CS_OPT_OFF;
        $this->{_details}  = 1 if $type == Capstone->CS_OPT_DETAIL &&
            $value == Capstone->CS_OPT_ON;
        $this->{_details}  = 0 if $type == Capstone->CS_OPT_DETAIL &&
            $value == Capstone->CS_OPT_OFF;
    }

    return $ret;
}

1;

__END__

=head1 NAME

Capstone - Perl extension for capstone-engine

=head1 SYNOPSIS

  use Capstone ':all';

  $cs = Capstone->new(CS_ARCH_X86, CS_MODE_64) || die "Can't init Capstone\n";
  @insn = $cs->dis("\x4c\x8d\x25\xee\xa6\x20\x00\x90\xcd\x80", 0x040000a, 0);

  foreach(@insn) {
    printf "0x%.16x    %s %s\n", $_->{address}, $_->{mnemonic}, $_->{op_str};
  }


=head1 DESCRIPTION

This module is a Perl wrapper of the capstone-engine library.

Capstone is a disassembly framework with the target of becoming the ultimate
disasm engine for binary analysis and reversing in the security community.

Created by Nguyen Anh Quynh, then developed and maintained by a small community,
Capstone offers some unparalleled features:

- Support multiple hardware architectures: ARM, ARM64 (ARMv8), Mips, PPC, Sparc,
  SystemZ, XCore and X86 (including X86_64).

- Having clean/simple/lightweight/intuitive architecture-neutral API.

- Provide details on disassembled instruction (called \u201cdecomposer\u201d by others).

- Provide semantics of the disassembled instruction, such as list of implicit
  registers read & written.

- Implemented in pure C language, with lightweight wrappers for C++, C#, Go,
  Java, Lua, NodeJS, Ocaml, Python, Ruby, Rust & Vala ready (available in
  main code, or provided externally by the community).

- Native support for all popular platforms: Windows, Mac OSX, iOS, Android,
  Linux, *BSD, Solaris, etc.

- Thread-safe by design.

- Special support for embedding into firmware or OS kernel.

- High performance & suitable for malware analysis (capable of handling various
  X86 malware tricks).

- Distributed under the open source BSD license.

Further information is available at http://www.capstone-engine.org

=head2 METHODS

=over 4

=item new(arch, mode)

  $cs = Capstone->new(CS_ARCH_X86, CS_MODE_32);

Create a new capstone object.
Take two arguments, the arch (CS_ARCH_*) and the mode (CS_MODE_*).
See cs_open() in capstone-engine documentation

=item dis(code, address, num)

  @ins = $cs->dis("\xcd\x80", 0x080480bc, 1);

Disassemble code, and return a list of disassembled instructions.

See cs_disasm() in capstone-engine documentation.


  foreach(@ins) {
    printf "%.16x  %-32s %s %s\n",
           $_->{address},
           hexlify($_->{bytes}),
           $_->{mnemonic},
           $_->{op_str};
  }

An instruction is represented with a hash ref, with fields :

=over 4

=item {address}

The address of the instruction

=item {mnemonic}

The mnemonic of the instruction

=item {op_str}

The operand string of the instruction

=item {bytes}

The raw bytes of the instruction

=item {regs_read}

If CS_OPT_DETAILS is set, it is a list of implicit registers read.

=item {regs_write}

If CS_OPT_DETAILS is set, it is a list of implicit registers modified.

=item {groups}

If CS_OPT_DETAILS is set, it is a list of group the instruction belong to.

=back

=item set_option(type, value)

  $cs->set_option(CS_OPT_SYNTAX, CS_OPT_SYNTAX_ATT);

Change the disassembly behavior.

See cs_option() in capstone-engine documentation.

=back

=head2 FUNCTIONS

=over 4

=item version()

  ($maj, $min) = Capstone::version();

Return a list of two scalars, the first is the major version, and the second
is the minor version

See cs_version() in capstone-engine documentation.

=item support(value)

  print "CS_ARCH_ALL supported\n" if(Capstone::support(CS_ARCH_ALL));

Test if the library support an architecture.
Use CS_ARCH_* constant (see capstone documentation)

See cs_support() in capstone-engine documentation.

=back

=head2 EXAMPLES

  #!/usr/bin/perl

  use ExtUtils::testlib;
  use Capstone ':all';

  use strict;
  use warnings;

  my $CODE = "\x4c\x8d\x25\xee\xa6\x20\x00\x90\x90\xcd\x80";
  my $ADDRESS = 0x040000;

  printf "Capstone version %d.%d\n", Capstone::version();
  print "Support ARCH_ALL : " . Capstone::support(CS_ARCH_ALL) . "\n\n";

  print "[+] Create disassembly engine\n";
  my $cs = Capstone->new(CS_ARCH_X86, CS_MODE_64)
      || die "[-] Can't create capstone object\n";

  print "[+] Set AT&T syntax\n";
  $cs->set_option(CS_OPT_SYNTAX, CS_OPT_SYNTAX_ATT)
      || die "[-] Can't set CS_OPT_SYNTAX_ATT option\n";

  print "[+] Disassemble some code\n\n";
  my @insn = $cs->dis($CODE, $ADDRESS, 0);

  foreach(@insn) {
      printf "    0x%.16x  %-30s   %s %s\n",
      $_->{address},
      hexlify($_->{bytes}),
      $_->{mnemonic},
      $_->{op_str};
  }

  print "[+] " . scalar(@insn) . " instructions disassembled\n";


  sub hexlify {
      my $bytes = shift;

      return join ' ', map { sprintf "%.2x", ord($_) } split //, $bytes;
  }

=head1 SEE ALSO

http://capstone-engine.org/

https://github.com/t00sh/perl-capstone

=head1 AUTHOR

Tosh, E<lt>tosh@t0x0sh.orgE<gt>

=head1 CONTRIBUTORS

Vikas N Kumar E<lt>vikas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2016 by Tosh

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

=cut
