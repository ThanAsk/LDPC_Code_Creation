import numpy as np
from scipy.optimize import root

# def f_roots(l_i,r_i):

#     N = 100
#     err = np.linspace(0,1,N)
#     z = np.zeros(N)
#     for i in range(N):
#         l_poly = np.polynomial.Polynomial(l_i)
#         r_poly = np.polynomial.Polynomial(r_i)
#         f_density = lambda x : err[i]*l_poly(1-r_poly(1-x))-x
#         x_o = np.array([0])
#         r = root(f_density,x_o)
#         z = r.x
        
    
#     return z

# print(f_roots(np.ones(3),np.ones(4)))

def find_thresh(l_i,r_i,steps):

    N = steps
    x_i = np.linspace(0,1,N)
    err = np.zeros(N)

    l_poly = np.polynomial.Polynomial(l_i)
    r_poly = np.polynomial.Polynomial(r_i)
    pfun =lambda x :  x / l_poly(1-r_poly(1-x))
    err = map(pfun, x_i)
    e_thresh = np.min(err)
    return e_thresh


