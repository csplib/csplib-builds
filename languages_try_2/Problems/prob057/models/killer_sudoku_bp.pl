/*

  Killer Sudoku in B-Prolog.

  http://en.wikipedia.org/wiki/Killer_Sudoku
  """
  Killer sudoku (also killer su doku, sumdoku, sum doku, addoku, or 
  samunamupure) is a puzzle that combines elements of sudoku and kakuro. 
  Despite the name, the simpler killer sudokus can be easier to solve 
  than regular sudokus, depending on the solver's skill at mental arithmetic; 
  the hardest ones, however, can take hours to crack.

  ...

  The objective is to fill the grid with numbers from 1 to 9 in a way that 
  the following conditions are met:

    * Each row, column, and nonet contains each number exactly once.
    * The sum of all numbers in a cage must match the small number printed 
      in its corner.
    * No number appears more than once in a cage. (This is the standard rule 
      for killer sudokus, and implies that no cage can include more 
      than 9 cells.)

  In 'Killer X', an additional rule is that each of the long diagonals 
  contains each number once.
  """

  Here we solve the problem from the Wikipedia page, also shown here
  http://en.wikipedia.org/wiki/File:Killersudoku_color.svg

  The output is:
    2 1 5 6 4 7 3 9 8
    3 6 8 9 5 2 1 7 4
    7 9 4 3 8 1 6 5 2
    5 8 6 2 7 4 9 3 1
    1 4 2 5 9 3 8 6 7
    9 7 3 8 1 6 4 2 5
    8 2 1 7 3 9 5 4 6
    6 5 9 4 2 8 7 1 3
    4 3 7 1 6 5 2 8 9


  Model created by Hakan Kjellerstrand, hakank@gmail.com
  See also my B-Prolog page: http://www.hakank.org/bprolog/

*/

% Licenced under CC-BY-4.0 : http://creativecommons.org/licenses/by/4.0/

go :-
        solve(1).

solve(ProblemName) :-
	problem(ProblemName, Board),
	killer_sudoku(Board,X),
	print_board(X).


killer_sudoku(Hints,X) :-

        N = 3,
        N2 is N*N,

        new_array(X,[N2,N2]),
        array_to_list(X,Vars),

        % The hints (from kakuro.pl)
        foreach([Sum|List] in Hints,[XLine],
                (XLine @= [X[R,C] : [R,C] in List, X[R,C] #> 0],
                 sum(XLine) #= Sum,
                 alldifferent(XLine))
         ),

	sudoku(N, X),
       
        labeling(Vars).
        
                  

%
% Ensure a Latin square, 
% i.e. all rows and all columns are different
%
alldifferent_matrix(Board) :-
        Rows @= Board^rows,
        foreach(Row in Rows, alldifferent(Row)),
        Columns @= Board^columns,
        foreach(Column in Columns, alldifferent(Column)).


% This is from sudoku.pl
sudoku(N, Board) :-
	N2 is N*N,

        BoardVar @= [BB : I in 1..N2, J in 1..N2, [BB], BB @= Board[I,J]],
        BoardVar :: 1..N2,

        alldifferent_matrix(Board),
	foreach(I in 1..N..N2, J in 1..N..N2, 
                [SubSquare],
                (
                    SubSquare @= [X : K in 0..N-1, L in 0..N-1, 
                                 [X], X @= Board[I+K,J+L]],
                    alldifferent(SubSquare)
                )
	),
	labeling([ff,down], BoardVar).



print_board(Board) :-
        N @= Board^length,
	foreach(I in 1..N,
                (foreach(J in 1..N,
                         [X],
                         (X @= Board[I,J],
                          (var(X) -> write('  _') ; format('  ~q', [X]))
                         )
                        ),
                 nl
                )
               ),
        nl.


problem(1, 
        [% The hints:
         %  [Sum, [list of indices in X]]
            [ 3, [1,1], [1,2]],
            [15, [1,3], [1,4], [1,5]],
            [22, [1,6], [2,5], [2,6], [3,5]],
            [ 4, [1,7], [2,7]],
            [16, [1,8], [2,8]],
            [15, [1,9], [2,9], [3,9], [4,9]],
            [25, [2,1], [2,2], [3,1], [3,2]],
            [17, [2,3], [2,4]],
            [ 9, [3,3], [3,4], [4,4]],
            [ 8, [3,6], [4,6],[5,6]],
            [20, [3,7], [3,8],[4,7]],
            [ 6, [4,1], [5,1]],
            [14, [4,2], [4,3]],
            [17, [4,5], [5,5],[6,5]],
            [17, [4,8], [5,7],[5,8]],
            [13, [5,2], [5,3],[6,2]],
            [20, [5,4], [6,4],[7,4]],
            [12, [5,9], [6,9]],
            [27, [6,1], [7,1],[8,1],[9,1]],
            [ 6, [6,3], [7,2],[7,3]],
            [20, [6,6], [7,6], [7,7]],
            [ 6, [6,7], [6,8]],
            [10, [7,5], [8,4],[8,5],[9,4]],
            [14, [7,8], [7,9],[8,8],[8,9]],
            [ 8, [8,2], [9,2]],
            [16, [8,3], [9,3]],
            [15, [8,6], [8,7]],
            [13, [9,5], [9,6],[9,7]],
            [17, [9,8], [9,9]]
        ]).

