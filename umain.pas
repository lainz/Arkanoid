unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  BGRAVirtualScreen, BGRABitmap, BGRABitmapTypes, BCTypes;

const
  BRICKWIDTH = 128;
  BRICKHEIGHT = 30;
  BALLRADIUS = 15;

type

  TBrick = record
    Shape: TRect;
    Visible: boolean;
  end;

  TBrickMap = array of TBrick;

  TBall = record
    Position: TPoint;
    Direction: TPoint;
    Visible: boolean;
  end;

  { TfrmMain }

  TfrmMain = class(TForm)
    BGRAVirtualScreen1: TBGRAVirtualScreen;
    Timer1: TTimer;
    procedure BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    Ball: TBall;
    Ship: TBrick;
    BrickMap: TBrickMap;
    function CreateBrick(x, y: integer): TBrick;
    function RandBool: boolean;
    function RectBallColliding(r: TRect): boolean;
  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: integer;
  x, y: integer;
begin
  Randomize;
  DoubleBuffered := True;

  // Level
  SetLength(BrickMap, 30);

  i := 0;
  for y := 0 to 5 do
  begin
    for x := 0 to 4 do
    begin
      BrickMap[i] := CreateBrick(x, y);
      Inc(i);
    end;
  end;

  Ship.Shape := Rect(0, Height - BRICKHEIGHT, BRICKWIDTH, Height);
  Mouse.CursorPos := Point(Screen.Width div 2, Screen.Height div 2);

  Ball.Position := Point(Width div 2, Ship.Shape.Top - BALLRADIUS);
  Ball.Direction := Point(-4, -3);
end;

procedure TfrmMain.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
var
  i: integer;
  mouse1: TPoint;
  win: boolean;
begin
  win := True;
  Mouse1 := ScreenToClient(Mouse.CursorPos);

  Ball.Position := Ball.Position + Ball.Direction;

  if (Ball.Position.X - BALLRADIUS < 0) or (Ball.Position.X + BALLRADIUS > Width) then
    Ball.Direction.x := -Ball.Direction.X;

  if (Ball.Position.Y - BALLRADIUS < 0) then
    Ball.Direction.Y := -Ball.Direction.Y;

  if (Ball.Position.Y > Height + BALLRADIUS) then
  begin
    Timer1.Enabled := False;
    Bitmap.TextRect(Rect(0, 0, Width, Height), 'Lose :(', taCenter, tlCenter, BGRAWhite);
  end;

  for i := 0 to High(BrickMap) do
    if BrickMap[i].Visible then
    begin
      win := False;

      Bitmap.Rectangle(BrickMap[i].Shape.Left, BrickMap[i].Shape.Top,
        BrickMap[i].Shape.Right, BrickMap[i].Shape.Bottom, BGRABlack, BGRAWhite, dmSet);

      if RectBallColliding(BrickMap[i].Shape) then
      begin
        BrickMap[i].Visible := False;
        if RandBool then
          Ball.Direction.x := -Ball.Direction.X;
        Ball.Direction.Y := -Ball.Direction.Y;
      end;
    end;

  Ship.Shape.Left := Mouse1.x - (BRICKWIDTH div 2);
  Ship.Shape.Right := Ship.Shape.Left + BRICKWIDTH;

  if RectBallColliding(Ship.Shape) then
  begin
    if RandBool then
      Ball.Direction.x := -Ball.Direction.X;
    Ball.Direction.Y := -Ball.Direction.Y;
  end;

  Bitmap.Rectangle(Ship.Shape.Left, Ship.Shape.Top, Ship.Shape.Right,
    Ship.Shape.Bottom, BGRABlack, BGRAWhite, dmSet);

  Bitmap.EllipseAntialias(Ball.Position.X, Ball.Position.Y, BALLRADIUS,
    BALLRADIUS, BGRABlack, 2, BGRAWhite);

  if Win then
  begin
    Timer1.Enabled := False;
    Bitmap.TextRect(Rect(0, 0, Width, Height), 'Win :)', taCenter, tlCenter, BGRAWhite);
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  BGRAVirtualScreen1.DiscardBitmap;
end;

function TfrmMain.CreateBrick(x, y: integer): TBrick;
begin
  Result.Shape := Rect(x * BRICKWIDTH, y * BRICKHEIGHT, x * BRICKWIDTH +
    BRICKWIDTH, y * BRICKHEIGHT + BRICKHEIGHT);
  Result.Visible := True;
end;

function TfrmMain.RandBool: boolean;
begin
  Result := Random > 0.5;
end;

function TfrmMain.RectBallColliding(r: TRect): boolean;
var
  distX, distY: double;
  dx, dy: double;
begin
  // https://stackoverflow.com/questions/21089959/detecting-collision-of-rectangle-with-circle
  distX := abs(Ball.Position.X - r.Left - r.Width / 2);
  distY := abs(Ball.Position.Y - r.Top - r.Height / 2);

  if (distX > (r.Width / 2 + BALLRADIUS)) then
    exit(False);
  if (distY > (r.Height / 2 + BALLRADIUS)) then
    exit(False);

  if (distX <= (r.Width / 2)) then
    exit(True);
  if (distY <= (r.Height / 2)) then
    exit(True);

  dx := distx - r.Width / 2;
  dy := disty - r.Height / 2;
  Result := (dx * dx + dy * dy <= (BALLRADIUS * BALLRADIUS));
end;

end.
