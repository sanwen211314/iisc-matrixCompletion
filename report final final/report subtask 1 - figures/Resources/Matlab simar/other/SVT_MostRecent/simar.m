%%                              Simar's code
% Control variables
n1 = 100;
n2 = 100;
r = 30;
VERBOSE=2;

% To construct image
imageSizeX = n1;
imageSizeY = n2;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = round(imageSizeX/2);
centerY = round(imageSizeY/2);
radius = 40;
width = 40;
M = 64.*( (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 <= radius.^2 & (rowsInImage - centerY).^2 + (columnsInImage - centerX).^2 >=(radius-width).^2);

% To construct rectangle
%a = 64 *  ones (9,1)
%b = [64 64 64 0 0 0 64 64 64]
%b = b'
%c = [64 64 64 0 64 0 64 64 64]
%c =c'
%M = [a a a b c c  b a a a]
%subplot(2,2,1)

image(M)	% Plot the original matrix

%%                     Parameters of SVT Algorithm code
randn('state',2009);
rand('state',2009);

%M = randn(n1,r)*randn(r,n2);

df = r*(n1+n2-r);
oversampling = 5;
m = min(5*df,round(.99*n1*n2) );
p  = m/(n1*n2);
Omega = randsample(n1*n2,m);  % this requires the stats toolbox
% a workaround, if you don't have the stats toolbox, is this:
%   Omega = randperm(n1*n2); Omega = Omega(1:m);

data = M(Omega);
% add in noise, if desired
sigma = 0;
% sigma = .05*std(data);
data = data + sigma*randn(size(data));


fprintf('Matrix completion: %d x %d matrix, rank %d, %.1f%% observations\n',...
    n1,n2,r,100*p);
fprintf('\toversampling degrees of freedom by %.1f; noise std is %.1e\n',...
    m/df, sigma );

tau = 5*sqrt(n1*n2);
delta = 1.2/p;

maxiter = 9999;
tol = 1e-4;

%% Approximate minimum nuclear norm solution by SVT algorithm
% Note: SVT, as called below, is setup for noiseless data 
%   (i.e. equality constraints).

fprintf('\nSolving by SVT...\n');
tic
[U,S,V,numiter] = SVT([n1 n2],Omega,data,tau,delta,maxiter,tol);
toc
    
X = U*S*V';

% Show results
fprintf('The recovered rank is %d\n',length(diag(S)) );
fprintf('The relative error on Omega is: %d\n', norm(data-X(Omega))/norm(data))
fprintf('The relative recovery error is: %d\n', norm(M-X,'fro')/norm(M,'fro'))
fprintf('The relative recovery in the spectral norm is: %d\n', norm(M-X)/norm(M))
