%% Example 6 - Hybrid
% Tries to reproduce discriminative result from table 1 in 
% "Learning algorithms for the classification Restricted boltzmann machine"
if ~ismac
    current_dir = pwd();
    cd('../..');
    addpath(genpath(pwd()));
    cd(current_dir)
    
    getenv('ML_GPUDEVICE')
    gpuidx = str2num(getenv('ML_GPUDEVICE')) + 1

    gpu = gpuDevice(gpuidx);
    disp(gpu);
    reset(gpu);
    wait(gpu);
    
    disp(['GPU memory available (Gb): ', num2str(gpu.FreeMemory / 10^9)]);
else 
    gpu = [];
end




name = 'example_6';
rng('default');rng(101);
 [train_x,val_x,test_x,train_y,val_y,test_y] = setupmnist(101,1);
f = fullfile(pwd,[name '.mat'])

% Setup DBN
sizes = [1500 ];   % hidden layer size
opts = dbncreateopts();
opts.alpha = 0.01; % 0 = discriminative, 1 = generative
opts.beta = 0;
opts.gpu   = 1;                  % use GPU other optsion are 0: CPU, -1: CPU test
opts.cdn = 1;   
opts.thisgpu = gpu;              % ref to gpu,  must be set if opts.gpu =1
opts.gpubatch = size(train_x,1); 
opts.outfile = [name '_intermediate.mat'];
opts.patience = 15;
opts.numepochs = 1000;
opts.testinterval = 1;
opts.init_type = 'cRBM';
opts.classRBM = 1;
opts.y_train = train_y;
opts.x_val = val_x;
opts.y_val = val_y;


%% Set learningrate and momentum
opts.learningrate = @(t,momentum) 0.05;
opts.momentum = @(t) 0;


[dbn, opts]  = dbnsetup(sizes, train_x, opts);  % train function 

rbm = dbn.rbm{1};
opts.gpu
opts.numepochs
disp(rbm);

fprintf('\n\n')

rbm = rbmtraingpu(rbm,train_x,opts);

 save(f,'rbm','opts');
% 
% 
% class_vec = zeros(100,size(train_y,2));
% for i = 1:size(train_y,2)
%     class_vec((i-1)*10+1:i*10,i) = 1;
% end
% digits = dbnsample(dbn,100,10000,class_vec);
% 
% 
% 
% 

