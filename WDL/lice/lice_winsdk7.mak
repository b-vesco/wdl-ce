# LICE makefile for Microsoft Windows SDK v7.0/v7.1
# (c) Theo Niessink 2009, 2010
# <http://www.taletn.com/>
#
# This file is provided 'as-is', without any express or implied warranty. In
# no event will the authors be held liable for any damages arising from the
# use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software in
#    a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.


# Usage:
#   Setenv [/Debug | /Release] [/x86 | /x64] [/xp | /vista | /2003 | /2008 | /win7]
#   NMAKE /f lice_winsdk7.mak [NOSSE2=1] [all | lib | lice | zlib | libpng | jpeglib | giflib | tinyxml]
#
# /Debug    Debug build
# /Release  Release build
# /x86      32-bit x86 code
# /x64      64-bit x64 code
# /xp       Windows XP SP2 (recommended)
# /vista    Windows Vista
# /2003     Windows Server 2003
# /2008     Windows Server 2008, Windows Vista SP1
# /win7     Windows 7
#
# NOSSE2=1  disables the use of SSE2 instructions
# all       builds the .lib file, keeping all intermediate files
# lib       builds the .lib file, and then deletes all intermediate files
# lice      compiles only LICE
# zlib      compiles only zlib
# libpng    compiles only libpng
# jpeglib   compiles only JPEG library
# giflib    compiles only giflib
# tinyxml   compiles only TinyXml
#
# Note: By default this makefile does a minimalist build of LICE (partial),
# zlib, and libpng only.


!IFNDEF CONFIGURATION
!	IFDEF NODEBUG
CONFIGURATION = Release
!	ELSE
CONFIGURATION = Debug
!	ENDIF
!ENDIF

!IFNDEF TARGET_CPU
!	IF "$(CPU)" == "i386"
TARGET_CPU = x86
!	ELSE IF "$(CPU)" == "AMD64"
TARGET_CPU = x64
!	ENDIF
!ENDIF


!IF "$(TARGET_CPU)" == "x86"
!	IFNDEF NOSSE2
PLATFORM = Win32
CPPFLAGS = $(CPPFLAGS) /arch:SSE2
!	ELSE
PLATFORM = Win32_noSSE2
!	ENDIF
CPPFLAGS = $(CPPFLAGS) /D "WIN32" /D "_CRT_SECURE_NO_WARNINGS"
!ELSE IF "$(TARGET_CPU)" == "x64"
PLATFORM = X64
!	IFDEF NOSSE2
!		MESSAGE Warning: NOSSE2 has no effect on x64 code
!		MESSAGE
!	ENDIF
CPPFLAGS = $(CPPFLAGS) /favor:blend /wd4267
!ELSE
!	ERROR Unsupported target CPU "$(TARGET_CPU)"
!ENDIF

OUTDIR = $(PLATFORM)/$(CONFIGURATION)
INTDIR = $(OUTDIR)

!MESSAGE LICE - $(CONFIGURATION)|$(PLATFORM)
!MESSAGE


CPPFLAGS = $(CPPFLAGS) /EHsc /GS- /GR- /D "_LIB" /D "_MBCS" /Oi /Ot /fp:fast /GF /MT /c /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /W3 /WX /wd4996 /nologo

!IF "$(CONFIGURATION)" == "Debug"
CPPFLAGS = $(CPPFLAGS) /D "_DEBUG" /RTCsu
!	IF "$(PLATFORM)" == "X64"
CPPFLAGS = $(CPPFLAGS) /Zi
!	ELSE
CPPFLAGS = $(CPPFLAGS) /ZI
!	ENDIF
!ELSE
CPPFLAGS = $(CPPFLAGS) /D "NDEBUG" /O2 /Ob2
!ENDIF

!MESSAGE $(CPP) $(CPPFLAGS)
!MESSAGE


all : "$(OUTDIR)/lice.lib"

"$(OUTDIR)" :
	@if not exist "$(OUTDIR)/" mkdir "$(OUTDIR)"

!IF "$(INTDIR)" != "$(OUTDIR)"
"$(INTDIR)" :
	@if not exist "$(INTDIR)/" mkdir "$(INTDIR)"
!ENDIF


ZLIB = \
"$(INTDIR)/adler32.obj" \
"$(INTDIR)/compress.obj" \
"$(INTDIR)/crc32.obj" \
"$(INTDIR)/deflate.obj" \
"$(INTDIR)/gzio.obj" \
"$(INTDIR)/infback.obj" \
"$(INTDIR)/inffast.obj" \
"$(INTDIR)/inflate.obj" \
"$(INTDIR)/inftrees.obj" \
"$(INTDIR)/trees.obj" \
"$(INTDIR)/uncompr.obj" \
"$(INTDIR)/zutil.obj"

zlib : $(ZLIB)

{../zlib}.c{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) "$<"


LIBPNG = \
"$(INTDIR)/png.obj" \
"$(INTDIR)/pngerror.obj" \
"$(INTDIR)/pnggccrd.obj" \
"$(INTDIR)/pngget.obj" \
"$(INTDIR)/pngmem.obj" \
"$(INTDIR)/pngpread.obj" \
"$(INTDIR)/pngread.obj" \
"$(INTDIR)/pngrio.obj" \
"$(INTDIR)/pngrtran.obj" \
"$(INTDIR)/pngrutil.obj" \
"$(INTDIR)/pngset.obj" \
"$(INTDIR)/pngtrans.obj" \
"$(INTDIR)/pngvcrd.obj" \
"$(INTDIR)/pngwio.obj" \
"$(INTDIR)/pngwrite.obj" \
"$(INTDIR)/pngwtran.obj" \
"$(INTDIR)/pngwutil.obj"

libpng : $(LIBPNG)

!IF "$(PLATFORM)" == "X64"
LIBPNGFLAGS = /D "PNG_NO_ASSEMBLER_CODE"
!ELSE
LIBPNGFLAGS = /D "__MMX__" /D "PNG_HAVE_MMX_COMBINE_ROW" /D "PNG_HAVE_MMX_READ_INTERLACE" /D "PNG_HAVE_MMX_READ_FILTER_ROW"
!ENDIF

LIBPNGFLAGS = $(LIBPNGFLAGS) /I "../zlib" /D "PNG_LIBPNG_SPECIALBUILD" /D "PNG_USE_PNGVCRD"

{../libpng}.c{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) $(LIBPNGFLAGS) "$<"


JPEGLIB = \
"$(INTDIR)/jcapimin.obj" \
"$(INTDIR)/jcapistd.obj" \
"$(INTDIR)/jccoefct.obj" \
"$(INTDIR)/jccolor.obj" \
"$(INTDIR)/jcdctmgr.obj" \
"$(INTDIR)/jchuff.obj" \
"$(INTDIR)/jcinit.obj" \
"$(INTDIR)/jcmainct.obj" \
"$(INTDIR)/jcmarker.obj" \
"$(INTDIR)/jcmaster.obj" \
"$(INTDIR)/jcomapi.obj" \
"$(INTDIR)/jcparam.obj" \
"$(INTDIR)/jcphuff.obj" \
"$(INTDIR)/jcprepct.obj" \
"$(INTDIR)/jcsample.obj" \
"$(INTDIR)/jctrans.obj" \
"$(INTDIR)/jdapimin.obj" \
"$(INTDIR)/jdapistd.obj" \
"$(INTDIR)/jdatadst.obj" \
"$(INTDIR)/jdatasrc.obj" \
"$(INTDIR)/jdcoefct.obj" \
"$(INTDIR)/jdcolor.obj" \
"$(INTDIR)/jddctmgr.obj" \
"$(INTDIR)/jdhuff.obj" \
"$(INTDIR)/jdinput.obj" \
"$(INTDIR)/jdmainct.obj" \
"$(INTDIR)/jdmarker.obj" \
"$(INTDIR)/jdmaster.obj" \
"$(INTDIR)/jdmerge.obj" \
"$(INTDIR)/jdphuff.obj" \
"$(INTDIR)/jdpostct.obj" \
"$(INTDIR)/jdsample.obj" \
"$(INTDIR)/jdtrans.obj" \
"$(INTDIR)/jerror.obj" \
"$(INTDIR)/jfdctflt.obj" \
"$(INTDIR)/jfdctfst.obj" \
"$(INTDIR)/jfdctint.obj" \
"$(INTDIR)/jidctflt.obj" \
"$(INTDIR)/jidctfst.obj" \
"$(INTDIR)/jidctint.obj" \
"$(INTDIR)/jidctred.obj" \
"$(INTDIR)/jmemmgr.obj" \
"$(INTDIR)/jmemnobs.obj" \
"$(INTDIR)/jquant1.obj" \
"$(INTDIR)/jquant2.obj" \
"$(INTDIR)/jutils.obj"

jpeglib : $(JPEGLIB)

{../jpeglib}.c{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) "$<"


GIFLIB = \
"$(INTDIR)/dgif_lib.obj" \
"$(INTDIR)/egif_lib.obj" \
"$(INTDIR)/gif_hash.obj" \
"$(INTDIR)/gifalloc.obj"

giflib : $(GIFLIB)

{../giflib}.c{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) /I "../giflib" /D "HAVE_CONFIG_H" "$<"


TINYXML = \
"$(INTDIR)/svgtiny_colors.obj" \
"$(INTDIR)/tinystr.obj" \
"$(INTDIR)/tinyxml.obj" \
"$(INTDIR)/tinyxmlerror.obj" \
"$(INTDIR)/tinyxmlparser.obj"

tinyxml : $(TINYXML)

"$(INTDIR)/svgtiny_colors.obj" : ../tinyxml/svgtiny_colors.c
	@$(CPP) $(CPPFLAGS) "$?"

{../tinyxml}.cpp{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) "$<"


LICE = \
"$(INTDIR)/lice.obj" \
"$(INTDIR)/lice_arc.obj" \
#"$(INTDIR)/lice_bmp.obj" \
#"$(INTDIR)/lice_colorspace.obj" \
#"$(INTDIR)/lice_gif.obj" \
#"$(INTDIR)/lice_gl_ctx.obj" \
#"$(INTDIR)/lice_glbitmap.obj" \
#"$(INTDIR)/lice_ico.obj" \
#"$(INTDIR)/lice_jpg.obj" \
#"$(INTDIR)/lice_jpg_write.obj" \
"$(INTDIR)/lice_line.obj" \
#"$(INTDIR)/lice_pcx.obj" \
"$(INTDIR)/lice_png.obj" \
#"$(INTDIR)/lice_png_write.obj" \
#"$(INTDIR)/lice_svg.obj" \
#"$(INTDIR)/lice_texgen.obj" \
#"$(INTDIR)/lice_text.obj" \
#"$(INTDIR)/lice_textnew.obj"

lice : $(LICE)

.cpp{$(INTDIR)}.obj :
	@$(CPP) $(CPPFLAGS) "$<"


LIB = \
$(ZLIB) \
$(LIBPNG) \
#$(JPEGLIB) \
#$(GIFLIB) \
#$(TINYXML) \
$(LICE)

LIB_FLAGS = /out:"$(OUTDIR)/lice.lib" /nologo

"$(OUTDIR)/lice.lib" : "$(OUTDIR)" "$(INTDIR)" $(LIB)
	@echo.
	@echo lib $(LIB_FLAGS)
	@lib $(LIB_FLAGS) $(LIB)

lib : "$(OUTDIR)/lice.lib" clear

clear :
	@if exist "$(INTDIR)/*.obj" erase "$(INTDIR:/=\)\*.obj"
	@if exist "$(INTDIR)/vc*.*" erase "$(INTDIR:/=\)\vc*.*"

clean : clear
	@if exist "$(OUTDIR)/lice.lib" erase "$(OUTDIR:/=\)\lice.lib"
