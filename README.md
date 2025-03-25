# Image Processing Script

This MATLAB script processes an input image by applying various filters and adding Gaussian noise. It then saves the results to separate output directories.

## Usage

1.  **Ensure MATLAB is installed:** This script requires MATLAB to run.
2.  **Save the script:** Save the provided code as a `.m` file (e.g., `process_image.m`).
3.  **Run the script:** Open MATLAB, navigate to the directory where you saved the script, and run it by typing `process_image` in the command window and pressing Enter.
4.  **Select an image:** The script will prompt you to select a BMP or TIFF image file.
5.  **View the results:** The script will create two output directories, `Task1` and `Task2`, in the same directory as the input image. `Task1` contains the original image and filtered versions of it. `Task2` contains noisy versions of the image and filtered versions of the noisy images.

## Script Description

The script consists of two main functions:

### `process_image()`

This function:

1.  **Prompts the user to select an image:** It uses `uigetfile` to allow the user to choose a BMP or TIFF image.
2.  **Reads the image:** It reads the selected image using `imread` and converts it to grayscale and double precision using `rgb2gray` and `im2double`.
3.  **Creates output directories:** It creates directories named `Task1` and `Task2` to store the processed images.
4.  **Saves the original image:** It saves the grayscale image in `Task1`.
5.  **Applies various filters to the original image:** It applies average, Gaussian, unsharp, and Laplacian filters using the `apply_filter` function and saves the results in `Task1`.
6.  **Adds Gaussian noise:** It adds Gaussian noise with different levels (0.01, 0.02, 0.05, 0.2) to the original image.
7.  **Saves noisy images and applies filters:** For each noisy image, it saves the noisy image in `Task2` and applies the same filters (average, Gaussian, unsharp, and Laplacian) using the `apply_filter` function, saving the results in `Task2`.
8.  **Prints image size data and PSNR values to the command window.**

### `apply_filter(img, filter_type, filter_size, output_dir, filename, noise_level)`

This function:

1.  **Applies a specified filter:** It applies the filter specified by `filter_type` (average, Gaussian, unsharp, or Laplacian) to the input image `img`.
2.  **Saves the filtered image:** It saves the filtered image in the specified `output_dir`.
3.  **Saves the difference image:** It saves the difference between original and filtered image in the specified `output_dir`.
4.  **Prints image and filter sizes and PSNR:** It prints the sizes of the filtered image and filter, as well as the Peak Signal-to-Noise Ratio (PSNR) between the filtered and original images.

## Dependencies

* MATLAB
* Image Processing Toolbox (for `imread`, `im2double`, `rgb2gray`, `imnoise`, `fspecial`, `conv2`, `imwrite`, `psnr`)