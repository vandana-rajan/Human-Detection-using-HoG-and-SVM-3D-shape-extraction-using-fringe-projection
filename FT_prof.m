%% for my image
clear all;close all;clc;
%% pre processing
img=imread('new_pic4.png');

if(size(img,3)>1)
    img=rgb2gray(img);
end
img=im2double(img);
figure; imshow(img); title('original');

bw = 15; %face2 image
%% fourier domain processing
img_fft = fftshift(fft2(img));
figure;imagesc(log(abs(img_fft))); title('image in fourier domain');
bandf = zeros(size(img_fft)); 

[cent_x cent_y] = find(abs(img_fft)==max(max(abs(img_fft))));
%img_fft(cent_x-7:cent_x+7,cent_y-7:cent_y+7) = 0;
%img_fft(cent_x-10:cent_x+10,cent_y-10:cent_y+10) = 0;%face image
img_fft(cent_x-20:cent_x+20,cent_y-20:cent_y+20) = 0;
figure;imagesc(log(abs(img_fft)));
[side_max_x,side_max_y] = find(abs(img_fft)==max(max(abs(img_fft))),1,'first');
bandf(side_max_x-10:side_max_x+10,side_max_y-8:side_max_y+8) = 1;
%bandf(side_max_x-8:side_max_x+8,side_max_y-8:side_max_y+8) = 1;
img_fft_bpf=img_fft.*bandf;
shift_x = cent_x - side_max_x;
shift_y = cent_y - side_max_y;
img_fft_bpf=circshift(img_fft_bpf,[shift_x shift_y]);
figure; imagesc(log(abs(img_fft_bpf))); title('filtered and shifted fourier');
img_rec = ifft2(fftshift(img_fft_bpf)); 
phi = atan(imag(img_rec)./real(img_rec));  
figure; imagesc(phi);title('wrapped phase map');colormap gray;
%% unwrapping
unwrp = unwrapping(img_rec);

figure;
imagesc(unwrp);
figure;
mesh(unwrp);

%% texture mapping
%img2 = im2double(imread('fringe_removed_face.png'));
img2 = im2double(imread('new_pic4.png'));
figure;warp(unwrp,img2); title('texture mapped face');
