%%
%**********************************
% Import signal
%**********************************
clc;
clear;
load('project1.mat');
n = single(primary);                                             % noise
d = single(reference);                                           % noise + speech
save('n.mat', 'n');

%%
%**********************************
% LMS
%**********************************
m = 15;
l = length(n);
%**************************************

E_lms = single(zeros(1,length(d)));
W_lms(:,l) = single(zeros(m,1));
mu_lms = 0.026;
    x = single(zeros(1,m-1+l));
    x(m:m-1+l) = n;
    X = single(zeros(m,l));
    
    for i = 1:l
        X(:,i) = x(i:i+m-1);
    end
    y = single(zeros(1,70000));

    for i = 1:l-1
        y(i+1) = W_lms(:,i).'*X(:,i);
        E_lms(i) = d(i) - y(i+1);
        W_lms(:,i+1) = W_lms(:,i)+mu_lms./(1+sum(X(:,i).^2)).*E_lms(i).*X(:,i);    
    end

    ERLE = zeros(1,length(d));
    for k = 1:length(d)
        ERLE(k) = 10.*log(mean(d(1:k).^2)/mean(E_lms(1:k).^2));                                 
    end
  

%%
%**************************************
% Plot
%**************************************
figure(1);
plot(W_lms.');
title('Weight Track')
xlabel('Iteration') 
ylabel('Value of Weight')

figure(2)
plot(E_lms.^2/sum(n.^2));
title('Learning Curve')
xlabel('Iteration')
ylabel('Absolute Value of Error')

figure(3)
stft(E_lms,fs,'Window',hamming(200,'periodic'),'OverlapLength',100);

figure(4)
plot(ERLE);
title('Improvement of SNR')
xlabel('Iteration')
ylabel('Value.dB')



% %%
% % ************************************************
% % Plot performance surface, only used in order = 2
% %*************************************************
% w_1 = min(W_lms(1,:)):0.01:max(W_lms(1,:));
% w_2 = min(W_lms(2,:)):0.01:max(W_lms(2,:));
% Per = zeros(length(w_2),length(w_1));
% for i = 1:length(w_1)
%     for j = 1:length(w_2)
%         Per(j,i) = mean((d-cat(1,w_1(i),w_2(j)).'*X).^2)/mean(n.^2);
%     end
% end
% 
% [w1,w2] = meshgrid(w_1,w_2);
% contour(w1,w2,Per,50);
% title('Contour')
% xlabel('w1')
% ylabel('w2')
