function process_image()
    [filename, pathname] = uigetfile({'*.bmp;*.tiff;*'}, 'Select original img (BMP or TIFF)');
    if isequal(filename, 0)
        fprintf('User cancelled file selection.\n');
        return;
    end
    img = imread(fullfile(pathname, filename));
    img = im2double(rgb2gray(img));
    
    % Prepare output directory
    output_dir1 = fullfile(pathname, 'Task1');
    if ~exist(output_dir1, 'dir')
        mkdir(output_dir1);
    end
    output_dir2 = fullfile(pathname, 'Task2');
    if ~exist(output_dir2, 'dir')
        mkdir(output_dir2);
    end

    % Print original image size and save
    [height, width] = size(img);
    fprintf('Original Image Size: %d x %d pixels\n\n', width, height);
    imwrite(img, fullfile(output_dir1, sprintf(filename, '.png')));

    apply_filter(img, 'average', 3, output_dir1, filename, '');
    apply_filter(img, 'gaussian', 3, output_dir1, filename, '');
    apply_filter(img, 'unsharp', 3, output_dir1, filename, '');
    apply_filter(img, 'laplacian', 3, output_dir1, filename, '');

    % Add Gaussian noise
    noise_levels = [0.01, 0.02, 0.05, 0.2];
    
    for i = 1:length(noise_levels)
        % Add noise
        noisy_img = imnoise(img, 'gaussian', 0, noise_levels(i));
        
        % Save noisy image
        imwrite(noisy_img, fullfile(output_dir2, sprintf('%s(%.2f).png', filename(1:end-4), noise_levels(i))));

        % Low-pass filters
        apply_filter(noisy_img, 'average', 3, output_dir2, filename, noise_levels(i));
        apply_filter(noisy_img, 'gaussian', 3, output_dir2, filename, noise_levels(i));
        
        % High-pass filters
        apply_filter(noisy_img, 'unsharp', 3, output_dir2, filename, noise_levels(i));
        apply_filter(noisy_img, 'laplacian', 3, output_dir2, filename, noise_levels(i));
    end
end


function apply_filter(img, filter_type, filter_size, output_dir, filename, noise_level)
    % Filter switch for low-pass filters
    % Avaliable filters: 'gaussian', 'sobel', 'prewitt', 'laplacian', 'log', 'average','unsharp', 'disk', 'motion'
    filename = filename(1:end-4);
    switch filter_type
        case 'average'
            filter = fspecial('average', filter_size);
            prefix = sprintf('f(%s,Md)_average%.2f', filename, noise_level);
        case 'gaussian'
            filter = fspecial('gaussian', filter_size, 0.5);
            prefix = sprintf('f(%s,Md)_gaussian%.2f', filename, noise_level);
        case 'unsharp'
            filter = fspecial('unsharp');
            prefix = sprintf('f(%s,Mg)_unsharp%.2f', filename, noise_level);
        case 'laplacian'
            filter = fspecial('laplacian');
            prefix = sprintf('f(%s,Mg)_laplacian%.2f', filename, noise_level);
        otherwise
            error('Unsupported filter type');
    end
    
    % Apply filter
    filtered_img = conv2(img, filter, 'same');
    
    % Print image and filter sizes
    [filtered_height, filtered_width] = size(filtered_img);
    [filter_height, filter_width] = size(filter);
    fprintf('%s Filter Processing:\n', upper(filter_type));
    fprintf('Filtered Image Size: %d x %d pixels\n', filtered_width, filtered_height);
    fprintf('Filter Size: %d x %d pixels\n', filter_width, filter_height);
    fprintf('PSNR: %d\n\n', psnr(filtered_img, img));
    
    % Save image
    imwrite(filtered_img, fullfile(output_dir, [prefix '.png']));
    imwrite((img-filtered_img), fullfile(output_dir, [prefix '-Id' '.png']));
end

process_image();