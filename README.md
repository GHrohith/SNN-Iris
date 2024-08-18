# Spiking Neural Network

This branch contains the IP for the LIF neuron, and jupyter notebooks to test the neuron with the Iris dataset.

Work in progress in the `develop` branch to implement a network on the FPGA fabric.

## Network Architecture

The network consists of an input layer with ten neurons, and an output layer with three neurons. The input layer is fully connected to the output layer. The network is trained on the Iris dataset.

![Network Architecture](docs/media/network_arch.png)

Each of the four features is encoded into ten neurons using gaussian receptive fields. The output layer consists of three LIF neurons, each representing one of the three classes of the Iris dataset. The network is trained using the STDP learning rule. The output neuron which fires the earliest is considered the predicted class.

## Steps to replicate the project

1. Clone the repository

`network_py/data/weights.csv` contains the weights of the trained network. It is generated in the `my_network_iris_train.ipynb` notebook.

2. Run the `my_network_iris_eval.ipynb` notebook to test the network locally.

3. Create a new Vivado project and create a new AXI4-Lite Peripheral IP. 

![IP Config Window](docs/media/lif_ip_config.png)

4. Delete the existing files from the IP sources, and add the files from the `hdl` and `src` directories in `vivado_proj/ip_repo/lif_ip_1_0` in the repository as sources. 

![IP Sources Window](docs/media/lif_ip_sources.png)

5. Package this IP and add it to the block design of the original Vivado project. Instantiate a Zynq Processing System, and run block automation and connection automation.

![Block Diagram](docs/media/lif_bd.png)

6. Create HDL wrapper and generate bitstream. Export the bitstream and hardware handoff file (which can be found in the `gen/hw_handoff` folder in the project directory).

7. Import the bitstream and hardware handoff files into the PYNQ environment. Follow the `fpga/my_network.ipynb` notebook to test the network on the PYNQ board.

## References

Adapted from [this](https://medium.com/@tapwi93/first-steps-in-spiking-neural-networks-da3c82f538ad).