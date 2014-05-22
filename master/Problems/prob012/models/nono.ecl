%
% ECLiPSe Nonogram Solver
%
% by Joachim Schimpf, IC-Parc, Imperial College, London, January 2001
%
% Problem:
%
% Nonograms are a popular puzzle, which goes by different names in
% different countries.  The player has to shade in squares in a grid so
% that blocks of consecutive shaded squares satisfy constraints given
% for each row and column.  Constraints typically indicate the sequence
% of shaded blocks (e.g. [3,1,2] means that there is a block of 3, then
% a gap of unspecified size, a block of length 1, another gap, and then
% a block of length 2). Data for sample problems is at the end of this file,
% for more see e.g. http://www.puzzle.gr.jp/nonogram/prob/0200_e.html
%   
% Solution:
%
% This code solves all the problems below, the hardest one so far
% being p200 (25x25):
%
%	ps,n2-n16	by propagation alone
%	p197,p199,p200	with search, takes a while
%
% The main idea here is to have a powerful constraint (line_lookahead/4)
% which solves a single-line subproblem and exports the generalised
% result (using ECLiPSe's propia library).
%
% No particularly clever search strategy is used, just first-fail.
%


:- lib(ic).
:- lib(propia).


go(Name, Board) :-
	data(Name, M, N, RowBlocks, ColBlocks),		% get the data
	check_data(M, N, RowBlocks, ColBlocks),

	dim(Board, [M,N]),
	(						% row constraints
	    for(I,1,M),
	    foreach(Blocks,RowBlocks),
	    foreach(Positions,RowPositions),
	    param(Board,N)
	do
	    matrix_row(Board, I, Line),
	    line_setup(N, Line, Blocks, Positions),
	    line_lookahead(N, Line, Blocks, Positions)
	),
	(						% column constraints
	    for(J,1,N),
	    foreach(Blocks,ColBlocks),
	    foreach(Positions,ColPositions),
	    param(Board,M)
	do
	    matrix_column(Board, J, Line),
	    line_setup(M, Line, Blocks, Positions),
	    line_lookahead(M, Line, Blocks, Positions)
	),
%	pretty_print(Board),

	flatten([RowPositions,ColPositions], AllPositions),	% search
	search(AllPositions, 0, first_fail, indomain, complete, []),
	pretty_print(Board).



% setup constraints on one line (row or column)
%
% Line is an array of boolean variables
% Blocks is a list of block sizes (integers)
% Positions is a list of variables representing the block positions
% Gaps is a list of variables representing the gap sizes

line_setup(NFields, Line, Blocks, Positions) :-
	length(Blocks, NBlocks),
	dim(Line, [NFields]),			% field variables
	Line[1..NFields] :: 0..1,
	length(Positions, NBlocks),		% position variables
	Positions :: 1..NFields,
	NGaps is NBlocks+1,			% gap variables
	length(Gaps, NGaps),
	Gaps = [Gap1|Gaps2N],
	once append(InnerGaps, [GapN], Gaps2N),
	[Gap1,GapN] :: 0..NFields,		% outer gaps can be empty
	InnerGaps :: 1..NFields,		% inner gaps must exist

	sum(Line[1..NFields]) #= sum(Blocks),
	(
	    foreach(Position,Positions),
	    fromto(Blocks, RightBlocks, RightBlocks1, []),
	    fromto([], LeftBlocks, [Block|LeftBlocks], _BlocksReverse),
	    fromto(Gaps2N, RightGaps, RightGaps1, []),
	    fromto([Gap1], LeftGaps, [RightGap|LeftGaps], _GapsReverse),
	    param(NFields,Line)
	do
	    RightBlocks = [Block|RightBlocks1],
	    RightGaps = [RightGap|RightGaps1],
	    LeftGaps = [LeftGap|_],
	    Position #= 1 + sum(LeftBlocks) + sum(LeftGaps),
	    Position #= 1 + NFields - (sum(RightBlocks) + sum(RightGaps)),
	    place_block(Line, Position, LeftGap, Block, RightGap)
	).



% constraint to update the Line-booleans that correspond
% to the block at Position and the adjacent gaps

place_block(Line, Position, LeftGap, BlockSize, RightGap) :-
	nonvar(Position),
	get_bounds(LeftGap, MinLeftGap, _),
	( for(I,Position-MinLeftGap,Position-1), param(Line) do
	    arg(I, Line, 0)
	),
	( for(I,Position,Position+BlockSize-1), param(Line) do
	    arg(I, Line, 1)
	),
	get_bounds(RightGap, MinRightGap, _),
	( for(I,Position+BlockSize,Position+BlockSize+MinRightGap-1), param(Line) do
	    arg(I, Line, 0)
	).
place_block(Line, Position, LeftGap, BlockSize, RightGap) :-
	var(Position),
	suspend(place_block(Line, Position, LeftGap, BlockSize, RightGap), 2,
		[Position->inst]).



% Lookahead constraint for one line:
% This uses propia to compute the most general solution
% for the single line subproblem

line_lookahead(NFields, Line, Blocks, Positions) :-
	suspend(
	    solve_line_problem(NFields, Line, Positions, Blocks),
	    7,
	    [Line->inst,Positions->ic:min,Positions->ic:max]
	) infers most.

solve_line_problem(NFields, Line, Positions, Blocks) :-
	line_setup(NFields, Line, Blocks, Positions),
	labeling(Positions).


%----------------------------------------------------------------------
% Auxiliaries
%----------------------------------------------------------------------

matrix_row(Mat, I, Row) :-
	Row is Mat[I].

matrix_column(Mat, J, Col) :-
	dim(Mat, [M, _N]),
	ColList is Mat[1..M,J],
	Col =.. [[]|ColList].

pretty_print(Board) :-
	dim(Board, [M,N]),
	( for(I,1,M), param(Board,N) do
	    ( for(J,1,N), param(Board,I) do
		X is Board[I,J],
		( X==0 -> write("  ")
		; X==1 -> write(" *")
		;         write(" ?")
		)
	    ), nl
	), nl.


%----------------------------------------------------------------------
% sample problems
%
% data(ProblemName, NRows, NColumns, RowBlocks, ColumnBlocks)
%----------------------------------------------------------------------

% from http://www-lp.doc.ic.ac.uk/UserPages/staff/ft/alp/humour/visual/nono.html
data(ps, 9, 8,
    [[3],[2,1],[3,2],[2,2],[6],[1,5],[6],[1],[2]],	% row blocks
    [[1,2],[3,1],[1,5],[7,1],[5],[3],[4],[3]]		% column blocks
).

% from http://www.pro.or.jp/~fuji/java/puzzle/nonogram/index-eng.html
data(n2, 10, 10,
    [[1],[3],[1,3],[2,4],[1,2],[2,1,1],[1,1,1,1],[2,1,1],[2,2],[5]],
    [[4],[1,3],[2,3],[1,2],[2,2],[1,1,1],[1,1,1,1],[1,1,1],[1,2],[5]]
).
data(n3, 10, 15,
    [[4],[1,1,6],[1,1,6],[1,1,6],[4,9],[1,1],[1,1],[2,7,2],[1,1,1,1],[2,2]],
    [[4],[1,2],[1,1],[5,1],[1,2],[1,1],[5,1],[1,1],[4,1],[4,1],[4,2],[4,1],[4,1],[4,2],[4]]
).
data(n4, 6, 6,
    [[2,1],[1],[2],[2],[1],[1,2]],
    [[1,2],[1],[2],[2],[1],[2,1]]
).
data(n5, 10, 10,
    [[3],[3],[1],[3],[6],[3],[3],[3,3],[2,2],[2,1]],
    [[1],[1,2],[1,2],[1,1],[2,5],[7],[2,5],[1],[2],[2]]
).
data(n6, 15, 15,
    [[5],[2,2],[1,1],[1,1],[4,4],[2,2,1,2],[1,3,1],[1,1,1,1],[2,7,2],[4,1,5],[2,1,1],[1,1,2],[1,1,1],[2,5,2],[3,4]],
    [[4],[2,2],[1,5],[1,2,2],[5,2,1],[2,1,1,2],[1,3,1],[1,1,6],[1,3,1],[2,1,2,2],[4,2,1],[1,1,1],[1,3,2],[2,2,3],[4]]
).
data(n16, 15, 15,
    [[4],[2,2],[2,2],[2,4,2],[2,1,1,2],[2,4,2],[1,2],[4,4,4],[1,1,1,1,1,1],[4,1,1,4],[1,1,1],[1,1,3],[10],[2,1],[4,1]],
    [[5,1],[2,1,1,1],[2,1,1,2],[2,3,3],[2,1],[2,3,6],[1,1,1,1,1],[1,1,1,1,1],[2,3,6],[2,1],[2,3,1],[2,1,1,1],[2,1,1,4],[7],[1,1]]
).
data(n19, R, C, RB, CB) :-
    data(p199, R, C, RB, CB).

% from http://www.puzzle.gr.jp/nonogram/prob/0200_e.html
data(p197, 20, 15,	% difficulty 7
    [[3],[1,2],[1,4],[1,1,2],[1,1,1,1],[1,3,2],[2,3,1],[1,1,1,2],[2,2,2],[1,1,2,2],[1,1,2,2],[1,1,1,1],[4,1,1],[2,2,2,1],[2,3,3],[2,2,3],[1,3,1,1],[2,1,1,1,2],[1,2,3],[1,6]],
    [[4,3],[6,1,2,3],[2,3],[6],[1,2,2],[1,1,2],[2,4,1,1],[1,1,2,2,2,1],[1,1,1,2,1,1],[1,3,2,3],[3,2,2],[4,3,4,2],[1,3,4,5],[2,2],[3]]
).
data(p199, 20, 20,	% difficulty 8
    [[1,1,4],[1,6],[1,1,1,1,2,3],[1,1,2,3],[3,1,2,3],[4,5,2,2],[7,3,2],[3,5,1,2],[2,2,4,1],[2,2,3,4],[2,5,2],[2,1,5,1],[2,2,3,1],[6,2,2],[1,7],[2,2,2],[1,4],[3,1,1],[1,1],[1,1]],
    [[6,1],[8,3],[3,2,1],[1,1,2,2,1],[1,2,2,1,1],[1,1,1,1],[2,3],[4,1,2,2],[5,2,1],[8,1,1],[7,2],[3,5,2],[2,5],[2,1,4],[2,2,2,2],[2,2,1,1,1],[3,1,1,1,1],[5,4,2,1],[7,4,1,1],[4]]
).
data(p200, 25, 25,	% difficulty 9
    [[1,1,2,2],[5,5,7],[5,2,2,9],[3,2,3,9],[1,1,3,2,7],[3,1,5],[7,1,1,1,3],[1,2,1,1,2,1],[4,2,4],[1,2,2,2],[4,6,2],[1,2,2,1],[3,3,2,1],[4,1,15],[1,1,1,3,1,1],[2,1,1,2,2,3],[1,4,4,1],[1,4,3,2],[1,1,2,2],[7,2,3,1,1],[2,1,1,1,5],[1,2,5],[1,1,1,3],[4,2,1],[3]],
    [[2,2,3],[4,1,1,1,4],[4,1,2,1,1],[4,1,1,1,1,1,1],[2,1,1,2,3,5],[1,1,1,1,2,1],[3,1,5,1,2],[3,2,2,1,2,2],[2,1,4,1,1,1,1],[2,2,1,2,1,2],[1,1,1,3,2,3],[1,1,2,7,3],[1,2,2,1,5],[3,2,2,1,2],[3,2,1,2],[5,1,2],[2,2,1,2],[4,2,1,2],[6,2,3,2],[7,4,3,2],[7,4,4],[7,1,4],[6,1,4],[4,2,2],[2,1]]
).

% the example quoted in Optima#65, Mathematical Programming Society Newsletter
data(optima, 20, 20,
    [[7,1],[1,1,2],[2,1,2],[1,2,2],[4,2,3],[3,1,4],[3,1,3],[2,1,4],[2,9],[2,1,5],[2,7],[14],[8,2],[6,2,2],[2,8,1,3],[1,5,5,2],[1,3,2,4,1],[3,1,2,4,1],[1,1,3,1,3],[2,1,1,2]],
    [[1,1,1,2],[3,1,2,1,1],[1,4,2,1,1],[1,3,2,4],[1,4,6,1],[1,11,1],[5,1,6,2],[14],[7,2],[7,2],[6,1,1],[9,2],[3,1,1,1],[3,1,3],[2,1,3],[2,1,5],[3,2,2],[3,3,2],[2,3,2],[2,6]]
).


% simple check for typos in the data

check_data(M, N, RowBlocks, ColBlocks) :-
	length(RowBlocks, M),
	length(ColBlocks, N),
	( foreach(Blocks,RowBlocks), fromto(0,S0,S1,RowTotal) do
	    S1 is S0+sum(Blocks)
	),
	( foreach(Blocks,ColBlocks), fromto(0,S0,S1,ColTotal) do
	    S1 is S0+sum(Blocks)
	),
	RowTotal = ColTotal,
	!.
check_data(_,_,_,_) :-
	writeln("Inconsistent input data!"),
	abort.

