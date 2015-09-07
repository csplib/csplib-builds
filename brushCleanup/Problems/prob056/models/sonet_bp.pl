/*

  SONET problem in B-Prolog.

  From the EssencePrime model in the Minion Translator examples:
  http://www.cs.st-andrews.ac.uk/~andrea/examples/sonet/sonet_problem.eprime
  """
  The SONET problem is a network design problem: set up a network between
  n nodes, where only certain nodes require a connection.
  Nodes are connected by putting them on a ring, where all nodes
  on a ring can communicate. Putting a node on a ring requires a so-called
  ADM, and each ring has a capacity of nodes, i.e. ADMs. There is a certain 
  amount of rings, r, that is available. The objective is to set up a network
  by using a minimal amount of ADMs.

  About the problem model

  The problem model has the amount of rings ('r'), amount of nodes('n'),
  the 'demand' (which nodes require communication) and node-capacity of each 
  ring ('capacity_nodes') as parameters.
  The assignement of nodes to rings is modelled by a 2-dimensional matrix 'rings',
  indexed by the amnount of rings and nodes. The matrix-domain is boolean:
  If the node in column j is assigned to the ring in row i, then rings[i,j] = 1 
  and 0 otherwise. So all the '1's in the matrix 'rings' stand for an ADM.
  Hence the objective is to minimise the sum over all columns and rows of matrix
  'rings'.
  """


  Model created by Hakan Kjellerstrand, hakank@gmail.com
  See also my B-Prolog page: http://www.hakank.org/bprolog/

*/

% Licenced under CC-BY-4.0 : http://creativecommons.org/licenses/by/4.0/

go :-
        R = 4,
        N = 5,
        Demand = [[0,1,0,1,0],
                  [1,0,1,0,0],
                  [0,1,0,0,1],
                  [1,0,0,0,0],
                  [0,0,1,0,0]],

        CapacityNodes = [3,2,2,1],

        % decision variables
        matrix(Rings,[R,N]),
        term_variables(Rings,Vars),
        Vars :: 0..1,

        % to optimize
        Z #= sum([(Rings[Ring,Client]) : Ring in 1..R, Client in 1..N]),

        
        % if there is a demand between 2 nodes, then there has to exist 
        % a ring, on which they are both installed
        foreach(Client1 in 1..N,
                Client2 in Client1+1..N,
                [Ring,R1,R2],
                (
                    Demand[Client1,Client2] =:= 1 ->
                        matrix_element(Rings,Ring,Client1,R1),
                        matrix_element(Rings,Ring,Client2,R2),
                        R1 + R2 #>= 2
                ;
                        true
                )
               ),
       
        % original comment:
        % capacity of each ring must not be exceeded     
        foreach(Ring in 1..R,
                sum([Rings[Ring,Client] : Client in 1..N]) #=< CapacityNodes[Ring] 
               ),

        % Z #= 7, % for showing all 6 optimal solutions

        minof(labeling(Vars),Z),
        % labeling(Vars),

        writeln(z:Z),
        foreach(RR in Rings, writeln(RR)),
        nl.
        
matrix_element(X, I, J, Val) :-
        nth1(I, X, Row),
        element(J, Row, Val).


matrix(_, []) :- !.
matrix(L, [Dim|Dims]) :-
        length(L, Dim),
        foreach(X in L, matrix(X, Dims)).

