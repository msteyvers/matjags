%% Calculating speedup factor running MCMC chains in parallel vs. serially
% The benefit of parallelization will only become apparent when running inference problems
% that take a long time to complete. In this case, the overhead cost of reading and writing
% files (which is done serially) is relatively small. In this example, we run the simple
% rate inference model with an extremely large burnin and calculate the speedup factor
% running seven MCMC chains in parallel vs. serially. This script was executed on a 
% 8 core machine. Performance benefits will vary between machines.
%
%%% Model Definition
% The BUGS example was taken from the WinBUGS course developed by Michael Lee and Eric-Jan
% Wagenmakers at <http://www.ejwagenmakers.com/BayesCourse/BayesBook.html>
%
% In this example, the goal is to infer a rate with the following model: 
%
% <html>
% <table border=0><tr><td>
% model {<br>
% &nbsp;&nbsp;  # Prior on Rate<br>
% &nbsp;&nbsp;  theta ~ dbeta(1,1)<br>
% &nbsp;&nbsp;  # Observed Counts<br>
% &nbsp;&nbsp;  k ~ dbin(theta,n)<br>
% }<br>
% </td><td>
% </table>
% </html>
%
% This script is stored in the text file "Rate_1.txt"
% The data is initialized in Matlab with variables k (number of successes) and n (total number of observations). In the rate problem, the
% goal is to get samples of theta, the rate of Beta distribution in the model 

%% Initialize variables and parameters
clear;
clc

% Data
k=8;  % number of observed successes
n=10; % number of observations total

% JAGS Parameters
nchains  = 7; % How Many Chains?
nburnin  = 15000000; % How Many Burn-in Samples?
nsamples = 5000;  % How Many Recorded Samples?

% Assign Matlab Variables to the Observed JAGS Nodes
datastruct = struct('k',k,'n',n);

% Initialize the values for each latent variable in each chain
for i=1:nchains
    S.theta = 0.5; % An Initial Value for the Success Rate
    init0(i) = S;
end

%% Open a pool of workers
if matlabpool('size') == 0
    matlabpool open 7; % initialize 7 local workers 
end

%% Calling JAGS to sample chains in parallel
doparallel = 1; % use parallelization
fprintf( 'Running JAGS...\n' );
tic
[samples, stats, structArray] = matjags( ...
    datastruct, ...                     % Observed data   
    fullfile(pwd, 'Rate_1.txt'), ...    % File that contains model definition
    init0, ...                          % Initial values for latent variables
    'doparallel' , doparallel, ...      % Parallelization flag
    'nchains', nchains,...              % Number of MCMC chains
    'nburnin', nburnin,...              % Number of burnin steps
    'nsamples', nsamples, ...           % Number of samples to extract
    'thin', 1, ...                      % Thinning parameter
    'monitorparams', {'theta'}, ...     % List of latent variables to monitor
    'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
    'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
    'cleanup' , 0  );         
time1 = toc

%% Calling JAGS to sample chains serially
doparallel = 0; % run serially
fprintf( 'Running JAGS...\n' );
tic
[samples, stats, structArray] = matjags( ...
    datastruct, ...                     % Observed data   
    fullfile(pwd, 'Rate_1.txt'), ...    % File that contains model definition
    init0, ...                          % Initial values for latent variables
    'doparallel' , doparallel, ...      % Parallelization flag
    'nchains', nchains,...              % Number of MCMC chains
    'nburnin', nburnin,...              % Number of burnin steps
    'nsamples', nsamples, ...           % Number of samples to extract
    'thin', 1, ...                      % Thinning parameter
    'monitorparams', {'theta'}, ...     % List of latent variables to monitor
    'savejagsoutput' , 1 , ...          % Save command line output produced by JAGS?
    'verbosity' , 1 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
    'cleanup' , 0  );                     % clean up of temporary files?
   
time2 = toc

%% Speedup factor
% Note that in this simulation an 8 core machine was used with 7 workers initialized by the Parallel Computing Toolbox
time2 / time1
