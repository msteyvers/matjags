%% Calculating Kappa Coefficient of Agreement
% This example illustrates hows JAGS handles a more complex hierarchical Bayesian model and compares the 
% output from JAGS with the output from WinBUGS
%
% The model was taken from the WinBUGS course developed by Michael Lee and Eric-Jan
% Wagenmakers at <http://www.ejwagenmakers.com/BayesCourse/BayesBook.html>
%
% Suppose we have data in the form of agreement counts between two methods, the objective
% method and the surrogate method. The data is represented by a vector d = [ a b c d ], where
%
% * a = number of times where both the objective and the aggregate methods decide 'one'
% * b = number of times where the objective method decides ‘one’ but the surrogate method decides ‘zero’
% * c = number of times where the objective method decides ‘zero’ but the surrogate method decides ‘one’
% * d = number of times where both methods decide ‘zero’
%
% The goal is to calculate Kappa, a standard measure of agreement 
% 
%%% Model definition
% We use a hierarchical Bayesian model to estimate Kappa: 
%
% <html>
% <table border=0><tr><td>
% # Kappa Coefficient of Agreement<br>
% model {<br>
%    &nbsp;&nbsp;# Underlying Rates<br>
%    &nbsp;&nbsp;# Rate objective method decides 'one'<br>
%    &nbsp;&nbsp;alpha ~ dbeta(1,1) <br>
%    &nbsp;&nbsp;# Rate surrogate method decides 'one' when objective method decides 'one'<br>
%    &nbsp;&nbsp;beta ~ dbeta(1,1)<br>  
%    &nbsp;&nbsp;# Rate surrogate method decides 'zero' when objective method decides 'zero'<br>
%    &nbsp;&nbsp;gamma ~ dbeta(1,1)<br>        
%    &nbsp;&nbsp;# Probabilities For Each Count<br>
%    &nbsp;&nbsp;pi[1] <- alpha*beta<br>
%    &nbsp;&nbsp;pi[2] <- alpha*(1-beta)<br>
%    &nbsp;&nbsp;pi[3] <- (1-alpha)*(1-gamma)<br>
%    &nbsp;&nbsp;pi[4] <- (1-alpha)*gamma<br>
%    &nbsp;&nbsp;# Count Data<br>   
%    &nbsp;&nbsp;d[1:4] ~ dmulti(pi[],n)<br>
%    &nbsp;&nbsp;# Derived Measures<br>   
%    &nbsp;&nbsp;# Rate surrogate method agrees with the objective method<br>
%    &nbsp;&nbsp;xi <- alpha*beta+(1-alpha)*gamma<br> 
%    &nbsp;&nbsp;# Rate of chance agreement<br>
%    &nbsp;&nbsp;psi <- (pi[1]+pi[2])*(pi[1]+pi[3])+(pi[2]+pi[4])*(pi[3]+pi[4])<br>
%    &nbsp;&nbsp;# Chance corrected agreement<br>
%    &nbsp;&nbsp;kappa <- (xi-psi)/(1-psi)<br>
% }<br>
% </td><td>
% </table>
% </html>

clear;
clc;

%% Defining Observed Data
d=[14 4 5 210];
%d=[20 7 103 417];
%d=[157 0 13 0];

% Derived Variables
n=sum(d);

% Create single Matlab structure with values for all the observed JAGS nodes
datastruct = struct('d',d,'n',n);

% MCMC parameters for JAGS
nchains=7; % How Many Chains?
nburnin=500; % How Many Burn-in Samples?
nsamples=1000; % How Many Recorded Samples?

% Initialize values all latent variables in all chains
for i=1:nchains
    S.alpha = 0.5; % An Initial Value
    S.beta = 0.5; % An Initial Value
    S.gamma = 0.5; % An Initial Value
    init0(i) = S;
end

%% Use JAGS to Sample
tic
doparallel = 0;
fprintf( 'Running JAGS\n' );
[samples, stats ] = matjags( ...
        datastruct, ...        
        fullfile(pwd, 'Kappa_1.txt'), ...
        init0, ...
        'doparallel' , doparallel, ...
        'nchains', nchains,...
        'nburnin', nburnin,...
        'nsamples', nsamples, ...
        'thin', 1, ...
        'monitorparams', {'kappa','xi','psi','alpha','beta','gamma','pi'}, ...
        'savejagsoutput' , 1 , ...
        'verbosity' , 1 , ...
        'cleanup' , 0  );

%%     
toc

%% Get the posterior means from JAGS:
stats.mean

%% Use WinBUGS to Sample
tic
fprintf( 'Running WinBUGS\n' );
[samples2, stats2] = matbugs(datastruct, ...
    fullfile(pwd, 'Kappa_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'kappa','xi','psi','alpha','beta','gamma','pi'}, ...
    'Bugdir', 'C:/WinBUGS14');
toc

%% Get the posterior means from WinBUGS:
stats2.mean

