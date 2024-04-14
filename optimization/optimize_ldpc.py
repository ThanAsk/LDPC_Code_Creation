
from scipy.optimize import linprog 
import numpy as np
import matplotlib.pyplot as plt
import csv

def write_to_csv(file_name,l_matrix,r_matrix,errors,rates):
    
    l_max = l_matrix.shape[1]
    r_max = r_matrix.shape[1]
    N = errors.size

    max_degrees = [l_max,r_max]

    with open(file_name,'w',newline = '') as file:
        writer = csv.writer(file)

        writer.writerow(max_degrees)
        for i in range(0,N):
            data  = [errors[i],rates[i],l_matrix[i,:],r_matrix[i,:]]
            writer.writerow(data)
        
        
                       

def compute_rate(r_i,l_i):

    lsize = l_i.size
    rsize = r_i.size

    l_den = np.ones(lsize) / np.arange(1,lsize+1)
    r_den = np.ones(rsize) / np.arange(1,rsize+1)

    rate = 1-(r_i.dot(r_den))/(l_i.dot(l_den))

    return rate 

def optimize_l(lmax,e,r_guess):

    #Initialize sum to be optimized
    obj = np.ones(lmax) / np.arange(1,lmax+1)
    
    #Function definitions
    r_poly = np.polynomial.Polynomial(r_guess)
    r_deriv = r_poly.deriv()
    f_coef = lambda x : 1 - r_poly(1-x)

    #Inequality constraints
    N = 100
    x_interval = np.linspace(0,1,N)
    powers = np.arange(0,lmax,dtype=int)
    A_ineq = np.zeros((N,lmax))

 
    b_ub = x_interval
    for i in range(0,N):
        A_ineq[i,:] = e* np.power(f_coef(x_interval[i]),powers)
   
    #Norm of l2 not too large
    if(e*r_deriv(1)>1e-12):
        l2 = np.zeros(lmax)
        l2[1] = 1
        A_ineq = np.append(A_ineq,[l2],axis = 0)
        b_ub = np.append(x_interval,1/(e*r_deriv(1)))

     #Equality constraints
    l1 = np.zeros(lmax)
    l1[0] = 1
    l_sum = [np.ones(lmax),l1]
    
    
    #Optimization of r_i coefficients (results more stable with options = cholesky:True ,tol < 1e09)
    opt = linprog(-obj, A_ineq, b_ub, l_sum, [1,0],options = None)  
    l_opt = opt.x
    
    
    
    return l_opt

def optimize_r(rmax,e,l_guess):
    
     
    #Initialize sum to be optimized
    obj = np.ones(rmax) / np.arange(1,rmax+1)

    #Function definitions
    l_poly = np.polynomial.Polynomial(l_guess)
    g_coef = lambda y : 1 - e*l_poly(y)

    #Inequality constraints
    N = 100         #Interval discrete step
    y_interval = np.linspace(0,1,N)
    powers = np.arange(0,rmax,dtype=int)
    A_ineq = np.zeros((N,rmax))

    for i in range(0,N):
        A_ineq[i,:] = -np.power(g_coef(y_interval[i]),powers)

    #Equality constraints
    r1 = np.zeros(rmax)
    r1[0] = 1
    r_sum = [np.ones(rmax),r1]

    #Optimization of r_i coefficients (results more stable with options = cholesky:True ,tol < 1e09)
    opt = linprog(obj, A_ineq, y_interval-1, r_sum, [1,0],options = None)
    r_opt = opt.x
    
    
    
    return r_opt

   
#not used in experiments
def check_concentrated_opt():
    r_avg = np.linspace(0,1,50)
    r = np.floor(r_avg)
    r_i = [(r*(r + 1 - r_avg))/r_avg,(r_avg-r*(r + 1 - r_avg))/r_avg] 

#Threshold calculation
def find_thresh(l_i,r_i,steps):

    N = steps
    x_i = np.linspace(0,1,N)
    err = np.zeros(N)

    l_poly = np.polynomial.Polynomial(l_i)
    r_poly = np.polynomial.Polynomial(r_i)
    pfun =lambda x :  x / l_poly(1-r_poly(1-x))
    err = list(map(pfun, x_i))
    e_thresh = np.min(err)
    return e_thresh



def main():

    #Compute coeffs for LDPC(5,7),(10,20),(20,40),(50,90)
    lmax = np.array([5,10,20,50])
    rmax = np.array([7,20,40,90])
    file_num = 0

    for l , r in zip(lmax,rmax):

        steps = 100
        ls = np.zeros([steps,l])
        rs = np.zeros([steps,r])
        rates = np.zeros(steps)
        errors = np.linspace(0,1,steps)
        thresholds = np.zeros(steps)

        #Error line 
        plt.plot(errors,1-errors)
        

        for i in range(0,steps):
            r_guess = np.ones(r) / r
            iter = 0

            #Iterate once (results may blow up with more iterations)
            l_guess = optimize_l(l,errors[i],r_guess)
            r_guess = optimize_r(r,errors[i],l_guess)
            
            #Store optimal coefficients for given error and compute optimal rate
            ls[i,:] = l_guess
            rs[i,:] = r_guess
            rates[i] = compute_rate(r_guess,l_guess)
            thresholds[i] = find_thresh(l_guess,r_guess,100)
                        
        plt.plot(errors,rates,label = str(l)+ ',' + str(r))  
        plt.ylim([0,1])

        #Store [error,rate,l_opt,r_opt] in csv file
        file_num += 1
        write_to_csv('file_'+str(file_num)+'.csv',ls,rs,errors,rates)
      
     

    plt.legend(framealpha=1, frameon=True)
    plt.xlabel('Error rate')
    plt.ylabel('Achievable Code Rate')
    #plt.ylabel('Rate / Maximum Rate (dB)')
    
    plt.show()



if __name__ == "__main__":
    main()