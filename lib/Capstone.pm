package Capstone;

use 5.022000;
use strict;
use warnings;

require Capstone_const;
require Exporter;

our @ISA = qw(Exporter);

# Generated by :
# perl -ne 'if(m/\s*(\S+)\s*=>\s*.+/){$h{$1}++} END{ print "qw(" . join(" ", keys %h) . ")\n"}' < lib/Capstone_const.pm

our %EXPORT_TAGS = ( 'all' => 
                     [ 
                       qw(CS_ARCH_SYSZ CS_MODE_V8 CS_OPT_OFF CS_OPT_SYNTAX_ATT CS_ARCH_MAX CS_MODE_MICRO CS_MODE_MIPSGP64 CS_ARCH_ARM64 CS_SUPPORT_X86_REDUCE CS_SUPPORT_DIET CS_MODE_ARM CS_MODE_16 CS_OPT_SKIPDATA_SETUP CS_OPT_DETAIL CS_OPT_ON CS_MODE_MIPS64 CS_MODE_V9 CS_ARCH_XCORE CS_OPT_SYNTAX_DEFAULT CS_OPT_SYNTAX_INTEL CS_OPT_MEM CS_ARCH_ALL CS_OPT_MODE CS_MODE_THUMB CS_OPT_SYNTAX_NOREGNAME CS_MODE_BIG_ENDIAN CS_MODE_MIPS32R6 CS_ARCH_X86 CS_OPT_SYNTAX CS_MODE_MIPS3 CS_ARCH_PPC CS_ARCH_ARM CS_ARCH_MIPS CS_MODE_32 CS_MODE_MIPS32 CS_MODE_64 CS_MODE_MCLASS CS_OPT_SKIPDATA CS_ARCH_SPARC)
                     ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.1';

require XSLoader;
XSLoader::load('Capstone', $VERSION);


# Preloaded methods go here.

sub new {
    my ($class, $arch, $mode) = @_;
    my $this = {};

    bless($this, $class);

    $this->{handle} = Capstone::open($arch, $mode);
    
    undef $this if(!defined($this->{handle}));

    return $this;
}

sub dis {
    my ($this, $code, $address, $num) = @_;

    return Capstone::disasm($this->{handle}, $code, $address, $num);
}

sub set_option {
    my ($this, $type, $value) = @_;

    return Capstone::option($this->{handle}, $type, $value);
}

1;

__END__

=head1 NAME

Capstone - Perl extension for capstone-engine

=head1 SYNOPSIS

  use Capstone ':all';

  $cs = Capstone->new(CS_ARCH_X86, CS_MODE_64) || die "Can't init Capstone\n";
  @insn = $cs->dis("\x4c\x8d\x25\xee\xa6\x20\x00jdslaaaaaaa", 0xFFFFFFFF, 0);

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

=head1 SEE ALSO

http://capstone-engine.org/

=head1 AUTHOR

Tosh, E<lt>tosh@t0x0sh.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 by Tosh

This library is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.                              

=cut
