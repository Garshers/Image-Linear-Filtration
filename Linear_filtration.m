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
    output_dir3 = fullfile(pathname, 'Task3');
    if ~exist(output_dir3, 'dir')
        mkdir(output_dir3);
    end

    % Print original image size and save
    [height, width] = size(img);
    fprintf('Original Image Size: %d x %d pixels\n\n', width, height);
    imwrite(img, fullfile(output_dir1, sprintf(filename, '.png')));

    apply_filter(img, 'average', 3, output_dir1, filename, '');
    apply_filter(img, 'gaussian', 3, output_dir1, filename, '');
    apply_filter(img, 'laplacian', 3, output_dir1, filename, '');

    % Add Gaussian noise
    noise_levels = [0.01, 0.02, 0.05, 0.2];
    
    for i = 1:length(noise_levels)
        % Add noise
        noisy_img = imnoise(img, 'gaussian', 0, noise_levels(i));
        
        % Save noisy image
        imwrite(noisy_img, fullfile(output_dir2, sprintf('%s(%.2f).png', filename(1:end-4), noise_levels(i))));

        % Low-pass filters
        filtered_img1 = apply_filter(noisy_img, 'average', 3, output_dir2, filename, noise_levels(i));
        filtered_img2 = apply_filter(noisy_img, 'gaussian', 3, output_dir2, filename, noise_levels(i));
        
        % High-pass filter
        apply_filter(filtered_img1, 'laplacian', 3, output_dir2, filename, sprintf('average_%.2f', noise_levels(i)));
        apply_filter(filtered_img2, 'laplacian', 3, output_dir2, filename, sprintf('gaussian_%.2f', noise_levels(i)));
    end

    % High-pass filter - unsharp mask
    filtered_img = apply_filter(img, 'unsharp', 3, output_dir3, filename, '');

    stretched_img = histogram_stretch(filtered_img);
    imwrite(stretched_img, fullfile(output_dir3, 'stretched_img.png'));

    clipped_stretched_img = histogram_stretch_with_clipping(filtered_img);
    imwrite(clipped_stretched_img, fullfile(output_dir3, 'clipped_stretched_img.png'));

    % Summary
    fprintf('Original Image k4 variable: %.4f\n\n', calculate_k4(img));
    fprintf('Filtered Image k4 variable: %.4f\n\n', calculate_k4(filtered_img));
    fprintf('Stretched-Filtered Image k4 variable: %.4f\n\n', calculate_k4(stretched_img));
    fprintf('Clipped-Stretched-Filtered Image k4 variable: %.4f\n\n', calculate_k4(clipped_stretched_img));
end


function filtered_img = apply_filter(img, filter_type, filter_size, output_dir, filename, noise_level)
    % Filter switch for low-pass filters
    % Avaliable filters: 'gaussian', 'sobel', 'prewitt', 'laplacian', 'log', 'average','unsharp', 'disk', 'motion'
    filename = filename(1:end-4);
    switch filter_type
        case 'average'
            filter = fspecial('average', filter_size);
            prefix = sprintf('f(%s,Md)_average_%.2f', filename, noise_level);
        case 'gaussian'
            filter = fspecial('gaussian', filter_size, 0.5);
            prefix = sprintf('f(%s,Md)_gaussian_%.2f', filename, noise_level);
        case 'unsharp'
            filter = fspecial('unsharp');
            prefix = 'UM';
            % Unsharp masking implementation
            blurred_img = conv2(img, fspecial('gaussian', filter_size, 1), 'same');
            mask = img - blurred_img;
            filtered_img = img + mask;
        case 'laplacian'
            filter = fspecial('laplacian');
            prefix = sprintf('f(%s,Mg)_%s_laplacian', filename, noise_level);
        otherwise
            error('Unsupported filter type');
    end
    
    % Apply filter, unless unsharp masking was applied
    if ~strcmp(filter_type, 'unsharp')
        filtered_img = conv2(img, filter, 'same');
    end
    
    % Print image and filter sizes
    [filtered_height, filtered_width] = size(filtered_img);
    [filter_height, filter_width] = size(filter);
    fprintf('%s Filter Processing: %s\n', upper(filter_type), prefix);
    fprintf('Filtered Image Size: %d x %d pixels\n', filtered_width, filtered_height);
    if ~strcmp(filter_type, 'unsharp')
        fprintf('Filter Size: %d x %d pixels\n', filter_width, filter_height);
    else
        fprintf('Filter Size: %d x %d pixels (for blur)\n', filter_size, filter_size);
    end
    fprintf('PSNR: %0.4f dB\n\n', psnr(filtered_img, img));
    
    % Save image
    imwrite(filtered_img, fullfile(output_dir, [prefix '.png']));
    imwrite((img-filtered_img), fullfile(output_dir, [prefix '-Id' '.png']));
end

function stretched_img = histogram_stretch(img)
    % Calculate the minimum and maximum pixel values
    min_val = double(min(img(:)));
    max_val = double(max(img(:)));
    
    % Perform histogram stretching
    stretched_img = uint8(255 * (double(img) - min_val) / (max_val - min_val));
end

function clipped_stretched_img = histogram_stretch_with_clipping(img)
    % Clip the image values
    clipped_img = histeq(img);
    
    % Histogram stretching on the clipped image
    clipped_stretched_img = histogram_stretch(clipped_img);
end


function k4 = calculate_k4(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    img_double = double(img);

    [M, N] = size(img);
    mean_val = mean(img_double(:));
    
    % Calculate Michelson variable k4
    k4 = (4 / (255^2 * M * N)) * sum((img_double(:) - mean_val).^2);
end

process_image();