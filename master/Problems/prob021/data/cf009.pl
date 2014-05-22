%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ECLiPSe module for solving Crossfigure Puzzle #9, from Thinks.com.
% See http://thinks.com/crosswords/number/xfig009.htm.
%
% This module written by Warwick Harvey, IC-Parc, wh@icparc.ic.ac.uk.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(cf009).

:- export cf009/1.

:- lib(fd).
:- use_module(crossfig).

%
% cf009(M):
%	Top-level goal for solving the puzzle.
%

cf009(M) :-
	constrain(M, Vars),
	labeling(Vars),
	print_matrix(M).


constrain(M, MVars) :-
	dim(M, [9, 9]),
	dim(T, [9, 9]),


	% Set up the constraints between the matrix elements and the
	% clue numbers.

	across(M, T, A1, 2, 1, 1),
	across(M, T, A3, 3, 1, 4),
	across(M, T, A5, 2, 1, 8),
	across(M, T, A7, 4, 2, 1),
	across(M, T, A8, 4, 2, 6),
	across(M, T, A9, 3, 3, 4),
	across(M, T, A11, 3, 4, 1),
	across(M, T, A13, 3, 4, 7),
	across(M, T, A15, 2, 5, 3),
	across(M, T, A16, 2, 5, 6),
	across(M, T, A17, 3, 6, 1),
	across(M, T, A20, 3, 6, 7),
	across(M, T, A22, 3, 7, 4),
	across(M, T, A24, 4, 8, 1),
	across(M, T, A25, 4, 8, 6),
	across(M, T, A27, 2, 9, 1),
	across(M, T, A28, 3, 9, 4),
	across(M, T, A29, 2, 9, 8),

	down(M, T, D1, 2, 1, 1),
	down(M, T, D2, 4, 1, 2),
	down(M, T, D3, 3, 1, 4),
	down(M, T, D4, 3, 1, 6),
	down(M, T, D5, 4, 1, 8),
	down(M, T, D6, 2, 1, 9),
	down(M, T, D10, 2, 3, 5),
	down(M, T, D11, 3, 4, 1),
	down(M, T, D12, 3, 4, 3),
	down(M, T, D13, 3, 4, 7),
	down(M, T, D14, 3, 4, 9),
	down(M, T, D18, 4, 6, 2),
	down(M, T, D19, 2, 6, 5),
	down(M, T, D21, 4, 6, 8),
	down(M, T, D22, 3, 7, 4),
	down(M, T, D23, 3, 7, 6),
	down(M, T, D24, 2, 8, 1),
	down(M, T, D26, 2, 8, 9),

	init_matrix(M, T, MVars),

	% Make a nice graphical display of the search if the user is
	% using TkECLiPSe.
	make_display_matrix(M, matrix),


	% Set up the clue constraints.

	/*
	Across

	 1 20 across divided by twelve
	 3 Four times 19 down
	 5 29 across minus nine
	 7 A square number
	 8 9 across times 6 down
	 9 10 down times six
	11 8 across divided by nine
	13 11 down minus twelve
	15 6 down plus nineteen
	16 A prime number
	17 13 down minus twenty-seven
	20 14 down plus ninety
	22 17 across minus twenty-five
	24 8 across minus 648
	25 5 down minus 287
	27 16 across minus forty-seven
	28 Eight times 15 across
	29 24 down minus thirty 
	*/

	A1 #= A20 / 12,
	A3 #= 4 * D19,
	A5 #= A29 - 9,
	square(A7),
	A8 #= A9 * D6,
	A9 #= 6 * D10,
	A11 #= A8 / 9,
	A13 #= D11 - 12,
	A15 #= D6 + 19,
	prime(A16),
	A17 #= D13 - 27,
	A20 #= D14 + 90,
	A22 #= A17 - 25,
	A24 #= A8 - 648,
	A25 #= D5 - 287,
	A27 #= A16 - 47,
	A28 #= 8 * A15,
	A29 #= D24 - 30,

	/*
	Down

	 1 26 down minus twenty-one
	 2 8 across plus 212
	 3 28 across minus 198
	 4 22 across minus forty
	 5 18 down minus 575
	 6 A square number
	10 A prime number
	11 11 across minus fifteen
	12 Eleven times 10 down
	13 13 across plus twenty-one
	14 8 across divided by twelve
	18 Five times 7 across
	19 Two times 6 down
	21 Five times 12 down
	22 8 across divided by nine
	23 18 down divided by eight
	24 9 across divided by three
	26 Two times 10 down 
	*/

	D1 #= D26 - 21,
	D2 #= A8 + 212,
	D3 #= A28 - 198,
	D4 #= A22 - 40,
	D5 #= D18 - 575,
	square(D6),
	prime(D10),
	D11 #= A11 - 15,
	D12 #= 11 * D10,
	D13 #= A13 + 21,
	D14 #= A8 / 12,
	D18 #= 5 * A7,
	D19 #= 2 * D6,
	D21 #= 5 * D12,
	D22 #= A8 / 9,
	D23 #= D18 / 8,
	D24 #= A9 / 3,
	D26 #= 2 * D10.

