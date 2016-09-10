%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ECLiPSe module for solving Crossfigure Puzzle #1, from Thinks.com.
% See http://thinks.com/crosswords/number/xfig001.htm.
%
% This module written by Warwick Harvey, IC-Parc, wh@icparc.ic.ac.uk.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(cf001).

:- export cf001/1.

:- lib(fd).
:- use_module(crossfig).

%
% cf001(M):
%	Top-level goal for solving the puzzle.
%

cf001(M) :-
	constrain(M, Vars),
	labeling(Vars),
	print_matrix(M).


constrain(M, MVars) :-
	dim(M, [9, 9]),
	dim(T, [9, 9]),


	% Set up the constraints between the matrix elements and the
	% clue numbers.

	across(M, T, A1, 4, 1, 1),
	across(M, T, A4, 4, 1, 6),
	across(M, T, A7, 2, 2, 1),
	across(M, T, A8, 3, 2, 4),
	across(M, T, A9, 2, 2, 8),
	across(M, T, A10, 2, 3, 3),
	across(M, T, A11, 2, 3, 6),
	across(M, T, A13, 4, 4, 1),
	across(M, T, A15, 4, 4, 6),
	across(M, T, A17, 4, 6, 1),
	across(M, T, A20, 4, 6, 6),
	across(M, T, A23, 2, 7, 3),
	across(M, T, A24, 2, 7, 6),
	across(M, T, A25, 2, 8, 1),
	across(M, T, A27, 3, 8, 4),
	across(M, T, A28, 2, 8, 8),
	across(M, T, A29, 4, 9, 1),
	across(M, T, A30, 4, 9, 6),

	down(M, T, D1, 4, 1, 1),
	down(M, T, D2, 2, 1, 2),
	down(M, T, D3, 4, 1, 4),
	down(M, T, D4, 4, 1, 6),
	down(M, T, D5, 2, 1, 8),
	down(M, T, D6, 4, 1, 9),
	down(M, T, D10, 2, 3, 3),
	down(M, T, D12, 2, 3, 7),
	down(M, T, D14, 3, 4, 2),
	down(M, T, D16, 3, 4, 8),
	down(M, T, D17, 4, 6, 1),
	down(M, T, D18, 2, 6, 3),
	down(M, T, D19, 4, 6, 4),
	down(M, T, D20, 4, 6, 6),
	down(M, T, D21, 2, 6, 7),
	down(M, T, D22, 4, 6, 9),
	down(M, T, D26, 2, 8, 2),
	down(M, T, D28, 2, 8, 8),

	init_matrix(M, T, MVars),

	% Make a nice graphical display of the search if the user is
	% using TkECLiPSe.
	make_display_matrix(M, matrix),


	% Set up the clue constraints.

	/*
	Across

	 1 27 across times two
	 4 4 down plus seventy-one
	 7 18 down plus four
	 8 6 down divided by sixteen
	 9 2 down minus eighteen
	10 Dozen in six gross
	11 5 down minus seventy
	13 26 down times 23 across
	15 6 down minus 350
	17 25 across times 23 across
	20 A square number
	23 A prime number
	24 A square number
	25 20 across divided by seventeen
	27 6 down divided by four
	28 Four dozen
	29 Seven gross
	30 22 down plus 450 
	*/

	A1 #= 2 * A27,
	A4 #= D4 + 71,
	A7 #= D18 + 4,
	A8 #= D6 / 16,
	A9 #= D2 - 18,
	A10 #= 6 * 144 / 12,
	A11 #= D5 - 70,
	A13 #= D26 * A23,
	A15 #= D6 - 350,
	A17 #= A25 * A23,
	square(A20),
	prime(A23),
	square(A24),
	A25 #= A20 / 17,
	A27 #= D6 / 4,
	A28 #= 4 * 12,
	A29 #= 7 * 144,
	A30 #= D22 + 450,

	/*
	Down

	 1 1 across plus twenty-seven
	 2 Five dozen
	 3 30 across plus 888
	 4 Two times 17 across
	 5 29 across divided by twelve
	 6 28 across times 23 across
	10 10 across plus four
	12 Three times 24 across
	14 13 across divided by sixteen
	16 28 down times fifteen
	17 13 across minus 399
	18 29 across divided by eighteen
	19 22 down minus ninety-four
	20 20 across minus nine
	21 25 across minus fifty-two
	22 20 down times six
	26 Five times 24 across
	28 21 down plus twenty-seven 
	*/

	D1 #= A1 + 27,
	D2 #= 5 * 12,
	D3 #= A30 + 888,
	D4 #= 2 * A17,
	D5 #= A29 / 12,
	D6 #= A28 * A23,
	D10 #= A10 + 4,
	D12 #= A24 * 3,
	D14 #= A13 / 16,
	D16 #= 15 * D28,
	D17 #= A13 - 399,
	D18 #= A29 / 18,
	D19 #= D22 - 94,
	D20 #= A20 - 9,
	D21 #= A25 - 52,
	D22 #= 6 * D20,
	D26 #= 5 * A24,
	D28 #= D21 + 27.

