%% for shiva sir's face
clear all;close all;clc;
%% pre processing
img=imread('face.png');
%img=imread('my_pic3.png');
if(size(img,3)>1)
    img=rgb2gray(img);
end
img=im2double(img);
figure; imshow(img); title('original');

bw = 22; %face image
img_fft = fftshift(fft2(img));
figure;imagesc(log(abs(img_fft))); title('image in fourier domain');
bandf = zeros(size(img_fft)); 

[cent_x cent_y] = find(abs(img_fft)==max(max(abs(img_fft))));
img_fft(cent_x-10:cent_x+10,cent_y-10:cent_y+10) = 0;
figure;imagesc(log(abs(img_fft)));
[side_max_x,side_max_y] = find(abs(img_fft)==max(max(abs(img_fft))),1,'first');
bandf(side_max_x-bw:side_max_x+bw,side_max_y-bw:side_max_y+bw) = 1;
img_fft_bpf=img_fft.*bandf;
figure; imagesc(log(abs(img_fft_bpf))); title('filtered fourier');
shift_x = cent_x - side_max_x;
shift_y = cent_y - side_max_y;
img_fft_bpf=circshift(img_fft_bpf,[shift_x shift_y]);
figure; imagesc(log(abs(img_fft_bpf))); title('filtered and shifted fourier');
img_rec = ifft2(fftshift(img_fft_bpf)); 
phi = atan(imag(img_rec)./real(img_rec));  
figure; imagesc(phi);title('wrapped phase map');colormap gray;
unwrp = unwrapping(img_rec);
figure;
imagesc(unwrp);
figure;
mesh(unwrp);
%% texture mapping
img2 = im2double(imread('fringe_removed_face.png'));
figure;warp(unwrp,img2); title('texture mapped face');