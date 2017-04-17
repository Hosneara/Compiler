%{


#include "TAC.h"
//#include "first.tab.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>

    void yyerror(const char *s);
    extern char* yylex();
    extern FILE *yyin;
    extern int yyparse(void);
    
    int true_label = 0, false_label = 0;
    int ind1 = 0, ind2 = 0;
    int param = 0, retnum = 0;
    int stackPosition = 0;
    
    
    void ReturnValues(char* str)
    {
    	int len = strlen(str);
    	printf("%d\n",strlen(str));
    	for(int i=0; i<len; i++)
    	{
    		if(str[i] == ' ')
    		{
    			str[i] = "";
    		}
    	}
    	printf("%d",strlen(str));
    }
    
    void paramValues(char* str)
    {
    	
    }
    
    
    void fillLabel(char* str, char* label, char* compString)
    {
    	int x = strlen(str);
    	
    	for(int i=0; i<x-4; )
    	{
    		if(strncmp(str+i, compString, 3) == 0)
    		{
    			strncpy(str+i, label, 3);
    		}
    		i++;
    	}
    }
    
    
    char* newlabel()
    {
		char* temp = malloc(4*sizeof(char));
        temp[0] = 'L';

        if(ind1 > 9)
        {
            temp[1] = (ind1/10) + 48;
            temp[2] = (ind1%10) + 48;
        }
        else
        {
            temp[1] = '_';
            temp[2] = ind1+48;
        }
        temp[3] = '\0';
        ind1++;
        return temp;

    }
    
    
    char* newtemp()
    {
    	char* temp = malloc(4*sizeof(char));
        temp[0] = 't';

        if(ind2 > 9)
        {
            temp[1] = (ind2/10) + 48;
            temp[2] = (ind2%10) + 48;
        }
        else
        {
            temp[1] = '_';
            temp[2] = ind2+48;
        }
        temp[3] = '\0';
        ind2++;
        return temp;
    }
    
    
    
%}

%union	{
        	char str[100];
        	ReturnType node;
        }

/* tokens */
%token <node> REAL INTEGER ID BOOLEAN
%token OR AND LE GE NE IF FI ELSE THEN SEMICOLON COMMA ASSIGN 
%token GREATER LESS NOT DO OD ELIF END_OF_FILE ADD SUB MUL DIV OP CP

%type <node> program stmts stmt selection iteration assignment alts alt
%type <node> guard vars expr exprs conjunction disjunction negation relation 
%type <node> sum subprogram term factor

%%
program:	stmts	{
						
						strcpy($$.code, $1.code);
						strcpy($$.mips, $1.mips);
						
						printf("3AC:\n%s\n", $$.code);
						printf("MIPS:\n%s\n", $$.mips);
					}
					
| END_OF_FILE	{	}
;

stmts:	stmt {		 				
				strcpy($$.code, $1.code);
				strcpy($$.next, $1.next);
				
				strcpy($$.mips, $1.mips);
			 }

|	stmts SEMICOLON stmt {
							
							strcpy($$.code, $1.code); 
						 	strcat($$.code, $3.code);
						 	
						 	strcpy($$.mips, $1.mips);
						 	strcat($$.mips, $3.mips);
						 }	
/*|  error stmt 
  {
    strcpy($$.code, $2.code);
	strcpy($$.next, $2.next);
    yyerrok  ;
     yyclearin;
  }
| stmt  error 
 {
     strcpy($$.code, $1.code);
	strcpy($$.next, $1.next);
     yyerrok  ;
     yyclearin;
}*/
;

stmt:	/*empty*/	{	}
|selection	{  
						strcpy($$.code, $1.code);
						strcpy($$.next, $1.next);
						
						strcpy($$.mips, $1.mips);
						
						
					
					}
/*| selection error 
 {
 	sprintf($$.code, "error here %s", $1.code);
 	strcpy($$.next, $1.next);
    //strcat(,"error is here\n"); strcat(str,$1.code);
    //strcat($$.code, str);
     yyerrok  ;
     yyclearin;
}
|error selection  
 {
   sprintf($$.code, "error here %s", $2.code);
   strcpy($$.next, $2.next);
    //strcat(,"error is here\n"); strcat(str,$1.code);
    //strcat($$.code, str);
     yyerrok  ;
     yyclearin;
}*/
			
|iteration	{	strcpy($$.code, $1.code); 
				strcpy($$.next, $1.next);
				
				strcpy($$.mips, $1.mips);
				
				

			}
/*| iteration error 
 {
 	sprintf($$.code, "error here %s", $1.code);
 	strcpy($$.next, $1.next);
   
     yyerrok  ;
     yyclearin;
}
|error iteration 
 {
   sprintf($$.code, "error here %s", $2.code);
   strcpy($$.next, $2.next);
   
     yyerrok  ;
     yyclearin;
}*/
			
|assignment	{	strcpy($$.code, $1.code); 

				strcpy($$.mips, $1.mips);
				strcpy($$.next, $1.next);
			}
/*| assignment error 
 {
 	sprintf($$.code, "error here %s", $1.code);
 	strcpy($$.next, $1.next);
    
     yyerrok  ;
     yyclearin;
}
|error assignment
 {
   sprintf($$.code, "error here %s", $2.code);
   strcpy($$.next, $2.next);
   
     yyerrok  ;
     yyclearin;
}	*/
;

selection:	IF alts FI	{		
								
								strcpy($$.next, newlabel());  
								strcpy($$.code, $2.code);
							
								fillLabel($$.code, $$.next, ",,,");
								
								strcpy($$.next, newlabel());  
							
								strcpy($$.code, $2.code);
							
								fillLabel($$.code, $$.next, ",,,");
								
								strcpy($$.mips, $2.mips);
								fillLabel($$.mips, $$.next, ",,,");
								strcpy($$.mips, $2.mips);
								fillLabel($$.mips, $$.next, ",,,");

								
								
								

			}
;

iteration:	DO alts OD  {	
							char* total = malloc(100*sizeof(char));
							total[0] = '\0';
							char* begin = malloc(4*sizeof(char));
							strcpy(begin, newlabel());
							
							strcpy($$.code,"");
							strcpy($$.next, newlabel()); 
							strcpy($$.code, $2.code);
							
							
							fillLabel($$.code, begin, ",,,");
							
							
							strcat(total, begin);
							strcat(total, ":\n\n");
							strcat(total, $$.code);
							
							strcpy($$.code, total);
							
							strcpy($$.mips,"");
							//strcpy($$.next, newlabel()); 
							strcpy($$.mips, $2.mips);
							
							
							fillLabel($$.mips, begin, ",,,");
							
							
							strcat(total, begin);
							strcat(total, ":\n");
							strcat(total, $$.mips);
							
							strcpy($$.mips, total);
								
							
							
						
							
						}
;

alts: 	alt	{
				strcpy($$.code, $1.code); 
				sprintf($$.code, "%s\ngoto %s\n", $$.code, ",,,");
				sprintf($$.code, "%s\n%s: \n",$$.code, ",,,");
				
				strcpy($$.mips, $1.mips); 
				sprintf($$.mips, "%s\nb %s\n", $$.mips, ",,,");
				sprintf($$.mips, "%s\n%s: \n",$$.mips, ",,,");
				
			}
			
|	   alts ELIF alt {	
						strcpy($$.code, $1.code);
						strcat($$.code, $3.code);
						
						strcpy($$.mips, $1.mips);
						strcat($$.mips, $3.mips);
						
						sprintf($$.code, "%s\n%s\n", $1.code, $3.code);
						
						sprintf($$.mips, "%s\n%s\n",$1.mips, $3.mips);
				  }
;

alt:	guard THEN stmts {  
							strcpy($$.truelabel, $1.truelabel);
							strcpy($$.falselabel, $1.falselabel);				
							
							sprintf($$.code, "%s \n %s\n",$1.code, $3.code);
							sprintf($$.mips, "%s\n%s\n\n",$1.mips, $3.mips);
							
																	
						 }
;

guard:	expr	{	strcpy($$.code, $1.code); 
					strcpy($$.truelabel, $1.truelabel);
					strcpy($$.falselabel, $1.falselabel);
					strcpy($$.place, $1.place);
					
					strcpy($$.mips, $1.mips);
				}
;



assignment:	vars ASSIGN exprs {		strcpy($$.code, $3.code);
									strcpy($$.mips, $3.mips);
									
									sprintf($$.code, "%s\n%s = %s\n", $$.code, $1.place, $3.place);
									sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nMOVE $a0 $t0\n",$$.mips, $1.mips, $3.mips);
							  }
							  
							  
|	vars ASSIGN subprogram ASSIGN exprs{	

						//printf("--- %s ---\n",$1);						
						
						//printf("Hello2");

						//printf("*** %s\n ***\n",$1.returns);
						printf("*** %s\n ***\n", $5.place);
					
						strcpy($$.code, $1.returns);
						int x = strlen($1.returns);
						char* temp = malloc(10*sizeof(char));
						temp[0] = $1.returns[0];
						printf("+++ %c %c +++ \n",temp[0], $1.returns[0]);
						retnum++;
				
							int i, j;
							printf("Hello ggg  %d\n", x);
							for(i=1, j=1; i<x; i+=2, j++)
							{
								temp[j] = $1.returns[i];
								printf("+++ %c %c +++ \n",temp[i], $1.returns[i]);
								retnum ++;
							}
							temp[j] = '\0';
						//printf("*** call %s\n %d %d ***\n",$3.code, param, retnum);
						
						//for(int i=0; i<retnum; i++)
						{
							//printf("***return %s\n ***\n",temp[0]);
						}
						
							//printf("--%s--\n",temp);
							//printf("---%d---\n",param);
							
							

										}
|	ASSIGN subprogram ASSIGN exprs	{}
|	vars ASSIGN subprogram ASSIGN	{}
|	ASSIGN subprogram ASSIGN	{}
;


vars :
vars COMMA ID 	{ 

	
	//sprintf($$.returns, "%s%s%s",$$.returns, $1.code, $3.code);
	sprintf($$.returns, "%s%s", $1.code, $3.code);
	
	
	printf("hello %s\n",$$.returns);

}


|ID 	{	
			strcpy($$.code, $1.code); 
	        strcpy($$.place, $1.code);
	        
	        strcpy($$.mips, $1.mips);
		}

;


subprogram:	ID	{
	strcpy($$.code, $1.code);
	strcpy($$.mips, $1.mips);
	printf("hello3");
	
}
;

exprs:
exprs COMMA expr {
						strcpy($$.code, $1.code);
						strcat($$.code, $3.code);
						
						strcpy($$.mips, $1.mips);
						strcat($$.mips, $3.mips);
					
						
						//sprintf($$.code, "%s%s", $1.code, $3.code);
						
						sprintf($$.place, "param %s\nparam%s\n", $1.place, $3.place);
						
						//strcat($$.place, $1.place);
						//strcat($$.place, $3.place);
						/*printf("** %d **\n",++param);
						printf("**%s **\n",$$.code);
						printf(" %s", $$.place);*/
						
					}
| expr 	{	strcpy($$.code, $1.code);
			strcpy($$.place, $1.place); 
			
			strcpy($$.mips, $1.mips);
			//printf("ultimate exprs %s \n", $$.code);
			
		}

;



expr:
disjunction {	//printf("$1.code %s\n",$1.code);
				strcpy($$.code, $1.code); 
				strcpy($$.truelabel, $1.truelabel);				
				strcpy($$.falselabel, $1.falselabel);
				strcpy($$.place, $1.place);
				
				strcpy($$.mips, $1.mips);
			}	
;


disjunction:
conjunction  {	strcpy($$.code, $1.code); 
				strcpy($$.truelabel, $1.truelabel);
				strcpy($$.falselabel, $1.falselabel);
				strcpy($$.place, $1.place);
				
				strcpy($$.mips, $1.mips);
				
}

| disjunction OR conjunction {	

							
								strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
			sprintf($$.code, "%s\n%s = %s || %s\n", $$.code, $$.place, $1.place, $3.place);			
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s : \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nOR $d0 $a0 $t0\nsw $d0 %s\n", $$.mips, $1.place, $3.place, $$.place);

						
						/*strcpy($$.code, $1.code);
						strcat($$.code, $$.falselabel);
						strcat($$.code, ":\n");
						
						
						
						strcat($$.code, $3.code); */
						
	
	

}
;


conjunction:
negation	{	strcpy($$.code, $1.code); 
				strcpy($$.truelabel, $1.truelabel );
				strcpy($$.falselabel, $1.falselabel);
				strcpy($$.place, $1.place);
				
				strcpy($$.mips, $1.mips);
				
				
				
			}
			
|	conjunction AND negation	{	
								strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
			sprintf($$.code, "%s\n%s = %s && %s\n", $$.code, $$.place, $1.place, $3.place);			
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s: \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nAND $d0 $a0 $t0\nsw $d0 %s\n", $$.mips, $1.place, $3.place, $$.place);


							
							/*strcpy($$.code, $1.code);  							
							strcat($$.code, $1.truelabel);
							strcat($$.code, ":\n");
							strcat($$.code, $3.code);*/
					
}
;



negation:
relation {	strcpy($$.code, $1.code); 
			strcpy($$.truelabel, $1.truelabel);
			strcpy($$.falselabel, $1.falselabel);
			strcpy($$.place, $1.place);
			
			strcpy($$.mips, $1.mips);
			
			//sprintf($$.mips, "%s\nlw $a0 %s\nADD $a0, $t0\nsw $a0 %s\n", $$.mips,$$.place, $1.place, $3.place);
			
			//printf("\npass it please %s\n",$$.code);
			
		
			
}
| NOT relation	{	strcpy($$.truelabel, $2.falselabel);
			strcpy($$.falselabel, $2.truelabel);

			strcpy($$.place, newtemp());
			strcpy($$.code, $2.code);
			
			strcpy($$.mips, $2.mips);
			
			sprintf($$.code, "%s\n%s = ~%s\n",$$.code, $$.place, $2.place);
			//sprintf($$.mips, "%s\nlw $a0 %s\nADD $a0, $t0\nsw $a0 %s\n", $$.mips,$$.place, $1.place, $3.place);
			
			
}
;

	
relation:
sum	{ 	strcpy($$.code, $1.code); 
		strcpy($1.truelabel, $$.truelabel);
		strcpy($1.falselabel, $$.falselabel);
		strcpy($$.place, $1.place);
		
		strcpy($$.mips, $1.mips);
		
		//printf(" |||| %s ", $$.code);
		
	}


| sum GREATER sum {	strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
					
					sprintf($$.code, "%s\n%s = %s > %s\n", $$.code, $$.place, $1.place, $3.place);
					
					
					sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s: \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
					
					sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nbgtz $a0 $t0 %s\nb %s\n%s: \n",  $$.mips, $1.place, $3.place, $$.truelabel, $$.falselabel, $$.truelabel);
					
					
	}


| sum LESS sum	{	strcpy($$.truelabel, newlabel());
			strcpy($$.falselabel, ",,,");
			strcpy($$.place, newtemp());
			strcpy($$.code, $1.code);
			strcat($$.code, $3.code);
			
			strcpy($$.mips, $1.mips);
			strcat($$.mips, $3.mips);
					
			sprintf($$.code, "%s\n%s = %s < %s\n", $$.code, $$.place, $1.place, $3.place);
					
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n\n%s:\n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nbltz $a0 $t0 %s\nb %s\n\n%s:\n",  $$.mips, $1.place, $3.place, $$.truelabel, $$.falselabel, $$.truelabel);
					
			
}


| sum LE sum	{ 
					strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
					
			sprintf($$.code, "%s\n%s = %s <= %s\n", $$.code, $$.place, $1.place, $3.place);			
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s: \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nblez $a0 $t0 %s\nb %s\n%s: \n",  $$.mips, $1.place, $3.place, $$.truelabel, $$.falselabel, $$.truelabel);
	
}


| sum NE sum	{ 	strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
					
			sprintf($$.code, "%s\n%s = %s ~= %s\n", $$.code, $$.place, $1.place, $3.place);			
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s: \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nbnez $a0 $t0 %s\nb %s\n%s: \n",  $$.mips, $1.place, $3.place, $$.truelabel, $$.falselabel, $$.truelabel);
	
}
| sum GE sum	{	strcpy($$.truelabel, newlabel());
					strcpy($$.falselabel, ",,,");
					strcpy($$.place, newtemp());
					strcpy($$.code, $1.code);
					strcat($$.code, $3.code);
					
					strcpy($$.mips, $1.mips);
					strcat($$.mips, $3.mips);
					
			sprintf($$.code, "%s\n%s = %s >= %s\n", $$.code, $$.place, $1.place, $3.place);			
			sprintf($$.code, "%s\nif %s goto %s\ngoto %s\n%s: \n", $$.code, $$.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
			//sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nADD $a0, $t0\nsw $a0 %s\n", $$.mips,$$.place, $1.place, $3.place);	
			sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nbgez $a0 $t0 %s\nb %s\n%s: \n",  $$.mips, $1.place, $3.place, $$.truelabel, $$.falselabel, $$.truelabel);
			
	
}
;





sum:
term	{   strcpy($$.code, $1.code); 
			strcpy($$.place, $1.place); 
			
			strcpy($$.mips, $1.mips);
			
			
		
			//printf("--- pass it 3 %s %s \n", $$.code, $$.place);
		}

| sum ADD term { strcpy($$.place, newtemp());

				 strcpy($$.code, $1.code);
				 strcat($$.code, $3.code);
				 
				 strcpy($$.mips, $1.mips);
				 strcat($$.mips, $3.mips);

				 sprintf($$.code, "%s\n%s = %s + %s\n", $$.code, $$.place, $1.place, $3.place);
				 sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nADD $d0 $a0 $t0\nsw $d0 %s\n", $$.mips, $1.place, $3.place, $$.place);	
				// printf("pass it 3 %s %s \n", $$.code, $$.place);
				
	
	
}


| sum SUB term { strcpy($$.place, newtemp());

				 strcpy($$.code, $1.code);
				 strcat($$.code, $3.code);
				 
				 strcpy($$.mips, $1.mips);
				 strcat($$.mips, $3.mips);

				 sprintf($$.code, "%s\n%s = %s - %s\n", $$.code, $$.place, $1.place, $3.place);
				 sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nSUB $d0 $a0 $t0\nsw $d0 %s\n", $$.mips, $1.place, $3.place, $$.place);	
				//printf("pass it 3 %s %s \n", $$.code, $$.place);
    
    
    
   
}


| SUB term {	strcpy($$.place, newtemp());
				strcpy($$.code, $2.code);
				sprintf($$.code, "%s\n%s = - %s\n", $$.code, $$.place, $2.place);
				//sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nMUL $a0, $t0\nsw $a0 %s\n", $$.mips, $$.place, $1.place, $3.place);	
				
				//printf("pass it 3 %s %s \n", $$.code, $$.place);
	}
;




term:
factor {	strcpy($$.code, $1.code);
			strcpy($$.place, $1.place);
			strcpy($$.mips, $1.mips);
			//printf("\npass it 2  %s %s\n",$$.code, $$.place);
			//sprintf($$.mips, "%s\nlw $a0 %s\nlw $t0 %s\nMUL $a0, $t0\nsw $a0 %s\n", $3.mips, $1.mips,$$.place, $1.place, $3.place);	
			
		

			
}


| term DIV factor {		strcpy($$.place, newtemp());
						sprintf($$.code, "%s = %s / %s\n",$$.place, $1.place, $3.place);
						sprintf($$.mips, "%s\n%s\nlw $a0 %s\nlw $t0 %s\nDIV $a0, $t0\nsw $a0 %s\n", $3.mips, $1.mips, $1.place, $3.place,$$.place);	
   
}

 
| term MUL factor {		strcpy($$.place, newtemp());
						sprintf($$.code, "\n%s  \n%s  \n%s = %s * %s\n",$3.code, $1.code, $$.place, $1.place, $3.place);
						sprintf($$.mips, "%s\n%s\nlw $a0 %s\nlw $t0 %s\nMULT $a0, $t0\nsw $a0 %s\n", $3.mips, $1.mips, $1.place, $3.place, $$.place);	
    stackPosition += 4;  
						
} 

;

/***factor → true | false | integer | real | id | ( expr )***/
factor: BOOLEAN {	strcpy($$.place, newtemp());
				sprintf($$.code, "%s = %s\n", $$.place, $1.code);
				//printf("%s\n",$$.code);
				//printf("pass it %s",$$.code);
				sprintf($$.mips, "\nli $a0 %s\nsw $a0 %s\n", $1.code, $1.code);	
				//printf("HI %s\n",$$.mips);
				
				param++;
				
				
				
			}


|INTEGER
{
	
    strcpy($$.place, newtemp());
    sprintf($$.code, "%s = %s\n", $$.place, $1.code);
    sprintf($$.mips, "\nli $a0 %s\nsw $a0 %s\n", $1.code, $1.code);	
    //stackPosition += 4;   
	param++;
   
}

| REAL
{
    strcpy($$.place, newtemp());
    sprintf($$.code, "%s = %s\n", $$.place, $1.code);
    sprintf($$.mips, "\nli $a0 %s\nsw $a0 %s", $1.code, $1.code);	
    stackPosition += 4;
    param++;
   
   
}
| OP expr CP
{
   strcpy($$.code, $2.code);
   
}
| ID 	{	

			strcpy($$.place, newtemp());
			
			sprintf($$.code, "\n%s = %s\n", $$.place, $1.code);
			
			sprintf($$.mips, "\nli $a0 %s\nsw $a0 %s\n", $1.code, $1.code);	
    stackPosition += 4;  
			
			param++;
			
    }
    
   


;


%%

void yyerror(const char *s)
{
    //fprintf(stderr, "Error:%s\n", s);
}
