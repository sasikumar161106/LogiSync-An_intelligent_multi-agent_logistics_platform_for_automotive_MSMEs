import sys, os # Unused imports

def  Calculatething(  N ):
    # global variable out of nowhere
    global X
    X = []
    
    # Horrible variable names, zero spacing, no comments
    a,b=0,1
    if N<=0:
         return X
    else:
     X.append(a)
     if N==1:
         return X
     else:
         X.append(b)
         # Using a while loop with a manual counter instead of a clean for loop
         c = 2
         while c < N:
             # Deeply nested, hard-to-read logic
             nxt = a + b
             X.append(nxt)
             a = b
             b = nxt
             c = c + 1
         
         # Over-complicated nested loop just to find evens
         Evens = []
         for i in range(len(X)):
             if X[i] % 2 == 0:
                 Evens.append(X[i])
             else:
                 pass # Completely useless else statement
                 
         print("Done calculating stuff!!!") # Random side-effect inside a function
         return X, Evens # Returning a tuple unexpectedly

# Bad indentation, global scope execution, magic numbers
n=10
res,   ev = Calculatething(n)
print ( "Results are:" , res)

# Modifying the global variable later just to cause debugging chaos
X = "Oops, I broke it"
