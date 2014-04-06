%% Example script: comparing JAGS to WinBUGS 
% This example illustrates how similar the JAGS-Matlab interface is to the WinBUGS-Matbugs interface
%
%%% Model definition
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
nburnin  = 1000; % How Many Burn-in Samples?
nsamples = 5000;  % How Many Recorded Samples?

% Assign Matlab Variables to the Observed JAGS Nodes
datastruct = struct('k',k,'n',n);

% Initialize the values for each latent variable in each chain
for i=1:nchains
    S.theta = 0.5; % An Initial Value for the Success Rate
    init0(i) = S;
end

%% Calling JAGS to sample
if matlabpool('size') == 0
    matlabpool open 7; % initialize 7 local workers 
end
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
    'cleanup' , 0 );                    % clean up of temporary files?
    
toc
% Note that execution times do not reflect linear speedfactor factors when execution times are short. In this case,
% the overhead produced by the file reading and writing will dominate performance.

%% Analyze JAGS samples
% samples.theta contains a matrix of samples where each row corresponds to the samples from a single MCMC chain
figure(1);clf;hold on;
eps=.01;bins=[eps:eps:1-eps];
count=hist(samples.theta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14);
xlabel('Rate','fontsize',16);
ylabel('Posterior Density','fontsize',16);
title( 'JAGS' );

%% Use WinBUGS to Sample through the MatBUGS interface
fprintf( 'Running WinBUGS...\n' );
tic
[samples, stats] = matbugs(datastruct, ...
    fullfile(pwd, 'Rate_1.txt'), ...
    'init', init0, ...
    'nChains', nchains, ...
    'view', 0, 'nburnin', nburnin, 'nsamples', nsamples, ...
    'thin', 1, 'DICstatus', 0, 'refreshrate',100, ...
    'monitorParams', {'theta'}, ...
    'Bugdir', 'C:/WinBUGS14');
toc

%% Analyze WinBUGS samples
figure(2);clf;hold on;
eps=.01;bins=[eps:eps:1-eps];
count=hist(samples.theta,bins);
count=count/sum(count)/eps;
ph=plot(bins,count,'k-');
set(gca,'box','on','fontsize',14);
xlabel('Rate','fontsize',16);
ylabel('Posterior Density','fontsize',16);
title( 'WinBUGS' );
