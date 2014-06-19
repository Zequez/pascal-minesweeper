Program Minesweeper;
Uses MinesweeperUnit in 'MinesweeperUnit.pas', Crt;
Var
  boardStatus: BoardStatusType;
  answer: Char;
Begin
  randomize;

  repeat
    writeln('1. Easy / 10 mines / 9x9 grid');
    writeln('2. Intermediate / 40 mines / 16x16 grid');
    writeln('3. Advanced / 99 mines / 16x30 grid');
    repeat
      readln(answer);
    until answer in ['1'..'3'];

    clrScr;

    case answer of
      '1': boardStatus := startNewGame(10, 9, 9);
      '2': boardStatus := startNewGame(40, 16, 16);
      '3': boardStatus := startNewGame(99, 16, 30);
    end;

    if boardStatus = won then 
      write('You won! ')
    else if boardStatus = playing then
      write('You quitted! ')
    else
      write('You lost! ');

    write('Start a new game? (Y/N) ');
    repeat
      readln(answer);
      if ord(answer) < 100 then answer := chr(ord(answer) + 32); {Lower case}
    until answer in ['y', 'n'];
    clrScr;
  until answer = 'n';
End.