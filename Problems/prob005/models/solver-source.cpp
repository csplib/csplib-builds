// Low Autocorrelation Binary Sequences

/* Code written by Ian Gent, Feb 1999, ipg@cs.strath.ac.uk

   For description of techniques used, see
	
   Symmetry Breaking during Search in Constraint Programming

   Ian P Gent and Barbara M Smith

   University of Leeds Research Report, 1999.

  This code does NOT contain the symmetry breaking techniques described
in the report, so if you are interested in those contact the authors.
  Instead two simple constraints break some symmetries, by asserting that
the first two bits are both -1.

*/

#include <ilsolver/ilcint.h>


IlcInt nBits;


IlcConstraint SimpleMod(IlcIntVar var, IlcInt mod, IlcIntVar remainder) { 
	return   (0 <= remainder) && (remainder < mod) 
		 && ( (var-remainder) == ((var-remainder)/mod)*mod) ;}
IlcConstraint SimpleMod(IlcIntVar var, IlcInt mod, IlcInt remainder) { 
	if ((0 <= remainder) && (remainder < mod)) {
	    return ( (var-remainder) == ((var-remainder)/mod)*mod) ;}
        else {var.getManager().fail(); } ;}
       // impossible to satisfy 
	
IlcConstraint SimpleMod(IlcInt var, IlcInt mod, IlcIntVar remainder) { 
	return   (0 <= remainder) && (remainder < mod) 
		 && ( (var-remainder) == ((var-remainder)/mod)*mod) ;}

void ModCorrelation(IlcIntVarArray Bits, IlcInt k, IlcIntVar Correlation) 
  { 
  IlcManager m = Bits.getManager();
  IlcIntArray BitValues(m,2,-1,1);

  IlcInt numCorrelations = IlcMin(k,nBits-k); 

  IlcIntVar Mod4Value(m,0,3);
  IlcIntVarArray Mod4Values(m,numCorrelations,0,3); 
  IlcIntVarArray SequenceCorrelations(m,numCorrelations); 

  IlcInt length ; 

  for(IlcInt ki = 0; ki < numCorrelations; ki++) { 
     length = (nBits-1-ki)/k;		// hope that's right -- CHECK!! 

		// length = 0 -> no correlation at this distance
		// although I think formula still holds as first value = 0?
     if (length > 0) { 
        IlcIntVarArray products(m,0,length,1,IlcIntVar(m,BitValues));
        for(IlcInt j = 0; j < length; j++) { 
	    products[j] = Bits[j*k + ki]*Bits[(j+1)*k+ki]; 
	   }  
        SequenceCorrelations[ki] = IlcSum(products); 

        m.add(SimpleMod(SequenceCorrelations[ki],2,length%2));

        m.add( SimpleMod((length%4) - (2*(Bits[ki] != Bits[ki+(length*k)])),
	                 4, Mod4Values[ki]) ); 
        m.add(SimpleMod(SequenceCorrelations[ki],4,Mod4Values[ki]));
        }
     else { 
        assert(1 == 0) ; // error if we get here!
        SequenceCorrelations[ki] = IlcIntVar(m,0,0);
        m.add( Mod4Values[ki] == 0) ; } ;
     };

  m.add(Correlation == IlcSum(SequenceCorrelations)); 

  m.add(SimpleMod(IlcSum(Mod4Values),4,Mod4Value));
  m.add(SimpleMod(Correlation,4,Mod4Value));
  }

void SimpleCorrelation(IlcIntVarArray Bits, IlcInt k, IlcIntVar Correlation) 
  { 
  IlcManager m = Bits.getManager();
  IlcIntArray BitValues(m,2,-1,1);

  IlcInt numCorrelations = IlcMin(k,nBits-k); 

  IlcIntVarArray SequenceCorrelations(m,numCorrelations); 

  IlcInt length ; 

  for(IlcInt ki = 0; ki < numCorrelations; ki++) { 
     length = (nBits-1-ki)/k;		// hope that's right -- CHECK!! 

		// length = 0 -> no correlation at this distance
		// although I think formula still holds as first value = 0?
     if (length > 0) { 
        IlcIntVarArray products(m,0,length,1,IlcIntVar(m,BitValues));
        for(IlcInt j = 0; j < length; j++) { 
	    products[j] = Bits[j*k + ki]*Bits[(j+1)*k+ki]; 
	   }  
        SequenceCorrelations[ki] = IlcSum(products); 
        m.add(SimpleMod(SequenceCorrelations[ki],2,length%2));
        }
     else { 
        assert(1 == 0) ; // error if we get here!
        SequenceCorrelations[ki] = IlcIntVar(m,0,0);
        }
     };
  m.add(Correlation == IlcSum(SequenceCorrelations)); 
  }
  
  



//$doc:CHOOSE
IlcChooseIndex1(IlcChooseOutermost,
                IlcMin(varIndex,nBits-varIndex),
                IlcIntVar)
//end:CHOOSE


//$doc:MAIN1
int main(int argc, char** argv){
  IlcManager m(IlcNoEdit);
  IlcInt i ; // loop variable

#if defined(ILCLOGFILE)
  m.openLogFile("labs.log");
#endif

  nBits = (argc > 1) ? atoi(argv[1]) : 10;

  IlcIntVar zeroVar(m,0,0); 

  IlcIntArray BitValues(m,2,-1,1);
  IlcIntVarArray Bits(m,0,nBits,1,IlcIntVar(m,BitValues));

// Set up domains of even/odd squares
  IlcIntArray EvenSquares(m,(nBits/2)+1) ;
  IlcIntArray OddSquares(m,(nBits+1)/2) ;
  for(i=0;i<(nBits/2)+1;i++) {
	EvenSquares[i]= IlcSquare(i*2); } 
  for(i=0;i<(nBits+1)/2;i++) {
	OddSquares[i]= IlcSquare(i*2+1); } 

//  IlcIntVarArray *shiftedBits = new(m.getHeap()) IlcIntVarArray[nBits]; 
  // IlcIntVarArray *differences = new(m.getHeap()) IlcIntVarArray[nBits]; 

  IlcIntVarArray Correlations(m,nBits,-nBits,nBits); 
  Correlations[0] = zeroVar; 	// so that Correlations[i] matches distance i
  
  //shiftedBits[0] = Bits;
 //  differences[0] = Bits;

  IlcIntVarArray SquareCorrelations(m,nBits); 
  SquareCorrelations[0] = zeroVar;

// general correlation mod work 

  for(i=1; i < nBits; i++) { 

      if (i <= (nBits/2)) {
         ModCorrelation(Bits,i,Correlations[i]) ;  }
      else { SimpleCorrelation(Bits,i,Correlations[i]) ; } ;

      if (((nBits-i) %2) == 0L) {
	SquareCorrelations[i] = IlcIntVar(m,EvenSquares); } 
      else {
	SquareCorrelations[i] = IlcIntVar(m,OddSquares); }
      m.add(SquareCorrelations[i] == IlcSquare(Correlations[i]));
      }

  IlcIntVar TotalSquareCorrelation = IlcSum(SquareCorrelations); 
	
  m.setObjMin(TotalSquareCorrelation); 


// simple symmetry breaking: 

     m.add(Bits[0] == -1);  m.add(Bits[1] == -1); 

//end:MAIN1
  /*
*/
//$doc:GEN2
  m.add(IlcGenerate(Bits,IlcChooseOutermost));
//end:GEN2 
//$doc:MAIN2
  

     while (m.nextSolution()) {
       m.out() << "Cost:\t" << TotalSquareCorrelation.getValue() << endl; 
       m.storeSolution(); 
       m.printInformation(); 
       m.out() << endl; 
       }

     m.restart(); 
     m.nextSolution();

     m.out() << "Optimal Correlation Cost:\t" << TotalSquareCorrelation.getValue() << endl;

     m.out() << Bits << endl; 
     m.out() << SquareCorrelations << endl; 

     m.printInformation(); 


#if defined(ILCLOGFILE)
  m.closeLogFile();
#endif
  m.end();
  return 0;
}

//end:MAIN2




