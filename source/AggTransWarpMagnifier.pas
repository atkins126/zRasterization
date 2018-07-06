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
unit AggTransWarpMagnifier;

interface

{$INCLUDE AggCompiler.inc}


uses
  AggBasics,
  AggTransAffine;

type
  TAggTransWarpMagnifier = class(TAggTransAffine)
  private
    FCenter: TPointDouble;
    FMagnification, FRadius: Double;
    procedure SetMagnification(M: Double);
    procedure SetRadius(R: Double);
  public
    constructor Create;

    procedure SetCenter(X, Y: Double);

    property Magnification: Double read FMagnification write SetMagnification;
    property radius: Double read FRadius write SetRadius;
  end;

implementation

procedure WarpMagnifierTransform(This: TAggTransWarpMagnifier; X, Y: PDouble);
var
  dx, dy, R, M: Double;

begin
  dx := X^ - This.FCenter.X;
  dy := Y^ - This.FCenter.Y;
  R := Sqrt(dx * dx + dy * dy);

  if R < This.FRadius then
    begin
      X^ := This.FCenter.X + dx * This.FMagnification;
      Y^ := This.FCenter.Y + dy * This.FMagnification;

      Exit;
    end;

  M := (R + This.FRadius * (This.FMagnification - 1.0)) / R;

  X^ := This.FCenter.X + dx * M;
  Y^ := This.FCenter.Y + dy * M;
end;

procedure WarpMagnifierTransformInverseTransform(This: TAggTransWarpMagnifier;
  X, Y: PDouble);
var
  T: TAggTransWarpMagnifier;
begin
  T := TAggTransWarpMagnifier.Create;
  try
    T := This;

    T.SetMagnification(1.0 / This.FMagnification);
    T.SetRadius(This.FRadius * This.FMagnification);
    T.Transform(@T, X, Y);
  finally
      T.Free;
  end;
end;

{ TAggTransWarpMagnifier }

constructor TAggTransWarpMagnifier.Create;
begin
  inherited Create;

  FCenter.X := 0.0;
  FCenter.Y := 0.0;

  FMagnification := 1.0;
  FRadius := 1.0;

  Transform := @WarpMagnifierTransform;
  InverseTransform := @WarpMagnifierTransformInverseTransform;
end;

procedure TAggTransWarpMagnifier.SetCenter(X, Y: Double);
begin
  FCenter.X := X;
  FCenter.Y := Y;
end;

procedure TAggTransWarpMagnifier.SetMagnification(M: Double);
begin
  FMagnification := M;
end;

procedure TAggTransWarpMagnifier.SetRadius(R: Double);
begin
  FRadius := R;
end;

end. 
