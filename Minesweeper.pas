Program Minesweeper;
Uses MinesweeperUnit in 'MinesweeperUnit.pas', Crt, Keyboard;
Var
  minesBoard, playerBoard: BoardType;
  i, j: Integer;
  key: Char;
  cursorX, cursorY: Byte;
  boardStatus: BoardStatusType;
Begin
  randomize;
  CursorBig;

  minesBoard := generateMinesBoard;
  playerBoard := generatePlayerBoard;
  drawBoard(playerBoard, minesBoard);

  cursorX := 1;
  cursorY := 1;
  repeat
    gotoXY(cursorX, cursorY);
    key := readKey;

    case key of
      #75 : if cursorX > 1            then dec(cursorX); {Left}
      #77 : if cursorX < BOARD_COLS  then inc(cursorX); {Right}
      #72 : if cursorY > 1            then dec(cursorY); {Up}
      #80 : if cursorY < BOARD_ROWS then inc(cursorY); {Down}
      'f': playerBoard := toggleFlag(cursorX, cursorY, playerBoard, minesBoard);
      ' ': playerBoard := activateTile(cursorX, cursorY, playerBoard, minesBoard);
    end;

    boardStatus := getBoardStatus(playerBoard, minesBoard);
  until (key = #27) or (key = 'q') or (boardStatus <> playing);

  gotoXY(1, BOARD_ROWS+1);

  if boardStatus = win then 
    writeln('You won!')
  else
    writeln('You lost!');
End.