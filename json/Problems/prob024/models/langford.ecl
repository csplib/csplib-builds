/*

  Langford's number problem in ECLiPSe.


  Langford's number problem (CSP lib problem 24)
  http://www.csplib.org/Problems/prob024/
  """
  Arrange 2 sets of positive integers 1..k to a sequence,
  such that, following the first occurence of an integer i, 
  each subsequent occurrence of i, appears i+1 indices later
  than the last. 
  For example, for k=4, a solution would be 41312432
  """
  
  * John E. Miller: Langford's Problem
    http://www.lclark.edu/~miller/langford.html
  
  * Encyclopedia of Integer Sequences for the number of solutions for each k
    http://www.research.att.com/cgi-bin/access.cgi/as/njas/sequences/eisA.cgi?Anum=014552
 

  Also, see the following models:
  * MiniZinc: http://www.hakank.org/minizinc/langford2.mzn
  * Comet   : http://www.hakank.org/comet/langford.co
  * Gecode/R: http://www.hakank.org/gecode_r/langford.rb



  Model created by Hakan Kjellerstrand, hakank@gmail.com
  See also my ECLiPSe page: http://www.hakank.org/eclipse/

*/

% Licenced under CC-BY-4.0 : http://creativecommons.org/licenses/by/4.0/

:-lib(ic).
:-lib(ic_global).
:-lib(ic_search).
%:-lib(branch_and_bound).
:-lib(listut).
:-lib(util). % for time
%:-lib(propia).



go :-
        K :: 2..8,
        indomain(K),
        writeln(K),
        Selection = first_fail,
        Choice = indomain_min,
        writeln([selection:Selection, choice:Choice]),
        time(findall([K,Backtracks,Solution,Position], langford(K,Solution,Position,Selection,Choice,Backtracks),
                L)),        
        length(L,Len),
        writeln(L),
        writeln(len:Len),
        nl,fail.


% For a specific K, check all possible variants of Selection and
% Choice methods.
go2 :-
        K = 8,
        selection(Selections),
        choice(Choices),
        writeln(K),
        ( foreach(Selection,Selections), param(Choices,K) do
              ( foreach(Choice, Choices),
                param(K,Selection) do
                   writeln([selection:Selection, choice:Choice]),
                   time(findall(Backtracks, 
                                langford(K,_Solution,_Position,Selection,Choice,Backtracks),
                                L)),
                   length(L,Len),
                   writeln(backtracks:L),
                   writeln(len:Len),
                   nl,
                   flush(output)
              )
        ).
        

selection([input_order,first_fail, anti_first_fail, smallest,largest,
           occurrence,most_constrained,max_regret]).
choice([indomain,indomain_min,indomain_max,indomain_middle,
         indomain_median,indomain_split, indomain_random,
         indomain_interval]).

        
langford(K, Solution, Position) :-
        langford(K, Solution, Position,first_fail,indomain,_Backtracks).


langford(K, Solution, Position,Selection,Choice,Backtracks) :-
        K2 is 2*K,
        length(Position, K2),
        Position :: 1..K2,

        length(Solution,K2),
        Solution :: 1..K,

        ic_global:alldifferent(Position),

        %  symmetry breaking
        nth1(1,Solution,Solution1),
        nth1(K2,Solution,SolutionK2),
        Solution1 #< SolutionK2,


        ( for(I,1,K), param(Position,Solution,K) do
              IK is I+K,
              nth1(IK, Position, PositionIK),
              nth1(I, Position, PositionI),
              I1 is I+1,
              PositionIK #= PositionI + I1,
              nth1(PositionI,Solution,SolutionPositionI),
              SolutionPositionI #= I,
              nth1(PositionIK,Solution,SolutionPositionIK),
              SolutionPositionIK #= I
        ),


        term_variables([Position,Solution], Vars),
        search(Vars,0,Selection,Choice,complete,[backtrack(Backtracks)]).




