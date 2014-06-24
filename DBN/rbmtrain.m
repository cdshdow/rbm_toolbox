function rbm = rbmtrain(rbm, x, opts)
%%RBMTRAIN trains a single RBM
% notation:
%    w  : weights
%    b  : bias of visible layer
%    c  : bias of hidden layer
%  Modified by S�ren S�nderby June 2014

% SETUP and checking
assert(isfloat(x), 'x must be a float');
assert(all(x(:)>=0) && all(x(:)<=1), 'all data in x must be in [0:1]');
m = size(x, 1);
numbatches = m / opts.batchsize;
assert(rem(numbatches, 1) == 0, 'numbatches not integer');

% RUN epochs
init_chains = 1;
chains = [];
for i = 1 : opts.numepochs
    kk = randperm(m);
    err = 0;
    for l = 1 : numbatches
        v0 = x(kk((l - 1) * opts.batchsize + 1 : l * opts.batchsize), :);
        
        if strcmp(opts.traintype,'PCD') && init_chains == 1
            % init chains in first epoch if Persistent contrastive divergence
            chains = v0;
            init_chains = 0;
        end
        
        % Collect rbm statistics with CD or PCD
        [dw,db,dc,c_err,chains] = rbmstatistics(rbm,v0,opts,opts.traintype,chains);
        
        %update weights, LR and momentum
        rbm = rbmapplygrads(rbm,dw,db,dc,i);
        err = err + c_err;
    end
    
    % display output
    epochnr = ['Epoch ' num2str(i) '/' num2str(opts.numepochs,4) '.'];
    avg_err = [' Avg recon. err: ' num2str(err / numbatches,4) '|'];
    lr_mom  = [' LR: ' num2str(rbm.curLR,4) '. Mom.: ' num2str(rbm.curMomentum,4)];
    disp([epochnr avg_err lr_mom]);
        
end
end
