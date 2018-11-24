#include <stdio.h>
#include <sys/types.h>
#include <libusb-1.0/libusb.h>
#include <stdlib.h>

void print_devs(libusb_device** devs) {
    libusb_device* dev;
    int i = 0;

    while((dev = devs[i++]) != NULL) {
        struct libusb_device_descriptor desc;
        int r = libusb_get_device_descriptor(dev,&desc);

        if (r < 0) {
            fprintf(stderr, "failed to get device descriptor");
            return;
        }
        printf("%04x:%04x (bus %d, device %d)\n",
               desc.idVendor, desc.idProduct,
               libusb_get_bus_number(dev), libusb_get_device_address(dev));

    }
}

int main(int argc, char** argv)
{
    printf("Usage: %s [debug_level:0-4]\n", argv[0]);
    unsigned int debug_level = 3;
    if (argc > 1)
    {
        debug_level = (unsigned int) atoi(argv[1]);
        if (debug_level > 4)
            debug_level = 3;
    }
    printf("Current Debug Level is: %d\n",debug_level);
    printf("Note: You may need root privileges, as opening devices requires write-permissions\n");
    libusb_device **devs;
    int return_value;
    ssize_t cnt;
    return_value = libusb_init(NULL);
    if (return_value < 0)
        return return_value;
    libusb_set_debug(NULL, debug_level);
    // list devices
    cnt = libusb_get_device_list(NULL, &devs);
    if (cnt < 0)
        return (int) cnt;
    printf("Available USB devices:\n");
    print_devs(devs);
    libusb_free_device_list(devs, 1);
    // Open Kingston Data Traveler
    // For a list of vendor & product ids visit: www.linux-usb.org/usb.ids
    libusb_device_handle* m_handle;
    m_handle = libusb_open_device_with_vid_pid(NULL, (uint16_t) 0x174c, (uint16_t)
            0x5106);

    if (m_handle == NULL) {
        printf("Can't open a Kingston DataTraveler 2.0!\n");
        libusb_exit(NULL);
        return 1;
    }

    printf("Opened USB device Kingston DataTraveler 2.0!\n");
    libusb_device* m_device = libusb_get_device(m_handle);
    struct libusb_device_descriptor m_device_descriptor;

    libusb_get_device_descriptor(m_device, &m_device_descriptor);
    printf("My device is connected on bus %d, port %d, with address %d\n", libusb_get_bus_number(m_device),
            libusb_get_port_number(m_device),libusb_get_device_address(m_device));
    struct libusb_config_descriptor m_config_descriptors[1];
    libusb_get_config_descriptor(m_device, 0, (struct libusb_config_descriptor **) &m_config_descriptors);
    return_value = libusb_get_device_speed(m_device);
    printf("My device's speed is: ");
    switch (return_value) {
        case LIBUSB_SPEED_LOW:
            printf("LOW");
            break;
        case LIBUSB_SPEED_FULL:
            printf("FULL");
            break;
        case LIBUSB_SPEED_HIGH:
            printf("HIGH");
            break;
        case LIBUSB_SPEED_SUPER:
            printf("SUPER");
            break;
        default:
            printf("BAD SPEED VALUE!");
    }
    printf("\n");
    int config_num;
    return_value = libusb_get_configuration(m_handle,&config_num);
    if (return_value != 0 )
        printf("Error getting configuration number for my device..!\n");
    else
        printf("My device is currently using configuration #%d\n", config_num);
    // Now we may set another configuration, claim an interface & send/receive data
    // On Linux we may need to detach the Kernel driver for the desired interface
    libusb_close(m_handle);
    libusb_exit(NULL);
    return 0;
}