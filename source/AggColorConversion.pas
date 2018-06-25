{ ****************************************************************************** }
{ * memory Rasterization with AGG support                                      * }
{ * by QQ 600585@qq.com                                                        * }
{ ****************************************************************************** }
{ * https://github.com/PassByYou888/CoreCipher                                 * }
{ * https://github.com/PassByYou888/ZServer4D                                  * }
{ * https://github.com/PassByYou888/zExpression                                * }
{ * https://github.com/PassByYou888/zTranslate                                 * }
{ * https://github.com/PassByYou888/zSound                                     * }
{ * https://github.com/PassByYou888/zAnalysis                                  * }
{ * https://github.com/PassByYou888/zGameWare                                  * }
{ * https://github.com/PassByYou888/zRasterization                             * }
{ ****************************************************************************** }

(*
  ////////////////////////////////////////////////////////////////////////////////
  //                                                                            //
  //  Anti-Grain Geometry (modernized Pascal fork, aka 'AggPasMod')             //
  //    Maintained by Christian-W. Budde (Christian@pcjv.de)                    //
  //    Copyright (c) 2012-2017                                                 //
  //                                                                            //
  //  Based on:                                                                 //
  //    Pascal port by Milan Marusinec alias Milano (milan@marusinec.sk)        //
  //    Copyright (c) 2005-2006, see http://www.aggpas.org                      //
  //                                                                            //
  //  Original License:                                                         //
  //    Anti-Grain Geometry - Version 2.4 (Public License)                      //
  //    Copyright (C) 2002-2005 Maxim Shemanarev (http://www.antigrain.com)     //
  //    Contact: McSeem@antigrain.com / McSeemAgg@yahoo.com                     //
  //                                                                            //
  //  Permission to copy, use, modify, sell and distribute this software        //
  //  is granted provided this copyright notice appears in all copies.          //
  //  This software is provided "as is" without express or implied              //
  //  warranty, and with no claim as to its suitability for any purpose.        //
  //                                                                            //
  ////////////////////////////////////////////////////////////////////////////////
*)
unit AggColorConversion;

interface

{$I AggCompiler.inc}

uses
  AggBasics,
  AggColor32,
  AggRenderingBuffer;

type
  CopyRow = procedure(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversion(Dst, Src: TAggRenderingBuffer; CopyRowFunctor: CopyRow);

procedure ColorConversionGray8ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionGray8ToRgb24(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionRgb565ToRgb555(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionBgr24ToRgb24(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionBgr24ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionBgr24ToBgra32(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionRgb24ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionRgb24ToBgra32(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionBgra32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionAbgr32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionAbgr32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionRgba32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);
procedure ColorConversionRgba32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);

procedure ColorConversionArgb32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);

implementation

procedure ColorConversion(Dst, Src: TAggRenderingBuffer;
  CopyRowFunctor: CopyRow);
var
  Y, Width, Height: Cardinal;
begin
  Width := Src.Width;
  Height := Src.Height;

  if Dst.Width < Width then
    Width := Dst.Width;

  if Dst.Height < Height then
    Height := Dst.Height;

  if Width > 0 then
    for Y := 0 to Height - 1 do
      CopyRowFunctor(Dst.Row(Y), Src.Row(Y), Width);
end;

procedure ColorConversionGray8ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderBgr.R)^ := Src^;
    PInt8u(PtrComp(Dst) + CAggOrderBgr.G)^ := Src^;
    PInt8u(PtrComp(Dst) + CAggOrderBgr.B)^ := Src^;

    Inc(PtrComp(Dst), 3);
    Inc(PtrComp(Src));
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionGray8ToRgb24(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderRgb.R)^ := Src^;
    PInt8u(PtrComp(Dst) + CAggOrderRgb.G)^ := Src^;
    PInt8u(PtrComp(Dst) + CAggOrderRgb.B)^ := Src^;

    Inc(PtrComp(Dst), 3);
    Inc(PtrComp(Src));
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionBgr24ToRgb24(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderBgr.R)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgb.R)^;
    PInt8u(PtrComp(Dst) + CAggOrderBgr.G)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgb.G)^;
    PInt8u(PtrComp(Dst) + CAggOrderBgr.B)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgb.B)^;

    Inc(PtrComp(Dst), 3);
    Inc(PtrComp(Src), 3);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionBgr24ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
begin
  Move(Src^, Dst^, Width * 3);
end;

procedure ColorConversionBgra32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderArgb.R)^ :=
      PInt8u(PtrComp(Src) + CAggOrderBgra.R)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.G)^ :=
      PInt8u(PtrComp(Src) + CAggOrderBgra.G)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.B)^ :=
      PInt8u(PtrComp(Src) + CAggOrderBgra.B)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.A)^ :=
      PInt8u(PtrComp(Src) + CAggOrderBgra.A)^;

    Inc(PtrComp(Dst), 4);
    Inc(PtrComp(Src), 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionAbgr32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderArgb.R)^ :=
      PInt8u(PtrComp(Src) + CAggOrderAbgr.R)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.G)^ :=
      PInt8u(PtrComp(Src) + CAggOrderAbgr.G)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.B)^ :=
      PInt8u(PtrComp(Src) + CAggOrderAbgr.B)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.A)^ :=
      PInt8u(PtrComp(Src) + CAggOrderAbgr.A)^;

    Inc(PtrComp(Dst), 4);
    Inc(PtrComp(Src), 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionRgba32ToArgb32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PInt8u(PtrComp(Dst) + CAggOrderArgb.R)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgba.R)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.G)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgba.G)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.B)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgba.B)^;
    PInt8u(PtrComp(Dst) + CAggOrderArgb.A)^ :=
      PInt8u(PtrComp(Src) + CAggOrderRgba.A)^;

    Inc(PtrComp(Dst), 4);
    Inc(PtrComp(Src), 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionBgr24ToBgra32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgra(Dst)^.B := PAggOrderBgr(Src)^.B;
    PAggOrderBgra(Dst)^.G := PAggOrderBgr(Src)^.G;
    PAggOrderBgra(Dst)^.R := PAggOrderBgr(Src)^.R;
    PAggOrderBgra(Dst)^.A := $FF;

    Inc(Dst, 4);
    Inc(Src, 3);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionRgb565ToRgb555(Dst, Src: PInt8u; Width: Cardinal);
var
  Rgb: Integer;
begin
  repeat
    Rgb := PInt16u(Src)^;

    PInt16u(Dst)^ := ((Rgb shr 1) and $7FE0) or (Rgb and $1F);

    Inc(PtrComp(Src), 2);
    Inc(PtrComp(Dst), 2);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionRgb24ToBgr24(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgr(Dst)^.R := PAggOrderRgb(Src)^.R;
    PAggOrderBgr(Dst)^.G := PAggOrderRgb(Src)^.G;
    PAggOrderBgr(Dst)^.B := PAggOrderRgb(Src)^.B;

    Inc(Src, 3);
    Inc(Dst, 3);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionAbgr32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgra(Dst)^.B := PAggOrderAbgr(Src)^.B;
    PAggOrderBgra(Dst)^.G := PAggOrderAbgr(Src)^.G;
    PAggOrderBgra(Dst)^.R := PAggOrderAbgr(Src)^.R;
    PAggOrderBgra(Dst)^.A := PAggOrderAbgr(Src)^.A;

    Inc(Src, 4);
    Inc(Dst, 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionArgb32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgra(Dst)^.B := PAggOrderArgb(Src)^.B;
    PAggOrderBgra(Dst)^.G := PAggOrderArgb(Src)^.G;
    PAggOrderBgra(Dst)^.R := PAggOrderArgb(Src)^.R;
    PAggOrderBgra(Dst)^.A := PAggOrderArgb(Src)^.A;

    Inc(Src, 4);
    Inc(Dst, 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionRgba32ToBgra32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgra(Dst)^.B := PAggOrderRgba(Src)^.B;
    PAggOrderBgra(Dst)^.G := PAggOrderRgba(Src)^.G;
    PAggOrderBgra(Dst)^.R := PAggOrderRgba(Src)^.R;
    PAggOrderBgra(Dst)^.A := PAggOrderRgba(Src)^.A;

    Inc(Src, 4);
    Inc(Dst, 4);
    Dec(Width);
  until Width = 0;
end;

procedure ColorConversionRgb24ToBgra32(Dst, Src: PInt8u; Width: Cardinal);
begin
  repeat
    PAggOrderBgra(Dst)^.B := PAggOrderRgb(Src)^.B;
    PAggOrderBgra(Dst)^.G := PAggOrderRgb(Src)^.G;
    PAggOrderBgra(Dst)^.R := PAggOrderRgb(Src)^.R;
    PAggOrderBgra(Dst)^.A := $FF;

    Inc(Src, 4);
    Inc(Dst, 4);
    Dec(Width);
  until Width = 0;
end;

end.
