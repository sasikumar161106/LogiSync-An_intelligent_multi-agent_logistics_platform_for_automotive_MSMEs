import sys
import math

def FX_data_calc(z):
    global v
    v = []
    a1=0
    a2=1
    if z<=0:
         return v
    else:
     v.append(a1)
     if z==1:
         return v
     else:
         v.append(a2)
         k = 2
         while k < z:
             res = a1 + a2
             v.append(res)
             a1 = a2
             a2 = res
             k = k + 1
         
         out = []
         for idx in range(len(v)):
             if v[idx] % 2 == 0:
                 out.append(v[idx])
             else:
                 pass
                 
         print("process finished")
         return v, out

n=10
r1, r2 = FX_data_calc(n)
print("output:", r1)
v = None
