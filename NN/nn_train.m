function net = nn_train(net, x, y, opts)
    m = size(x, 1);

    if strcmp(class(x), 'uint8')
        x = double(x) / 255;
    end

    if strcmp(class(y), 'uint8')
        y = double(y) / 255;
    end

    batchsize = opts.batchsize;
    numepochs = opts.numepochs

    numbatches = m / batchsize;

    if rem(numbatches, 1) ~= 0
        error('numbatches not integer');
    end

%    net.rL = [];
    net.rL = zeros(1, numepochs * numbatches);
    n = 1;
    for i = 1 : numepochs
        tic;

        kk = randperm(m);
        for l = 1 : numbatches
            batch_x = x(kk((l - 1) * batchsize + 1 : l * batchsize), :);
            batch_y = y(kk((l - 1) * batchsize + 1 : l * batchsize), :);

            net = nn_ff(net, batch_x, batch_y);
%                if rand() < 1e-3
%                    disp 'Performing numerical gradient checking ...';
%                    nn_checknumgrad(net, x(i, :), y(i, :));
%                    disp 'No errors found ...';
%                end
            net = nn_bp(net);
            net = nn_applygrads(net);

%            if isempty(net.rL)
            if n == 1
                net.rL(n) = net.L;
            end

            net.rL(n + 1) = 0.99 * net.rL(n) + 0.01 * net.L;
            n = n + 1;
        end

        toc;
        disp(['epoch ' num2str(i) '/' num2str(numepochs)]);
    end
end