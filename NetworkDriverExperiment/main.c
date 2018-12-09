#include <stdio.h>
#include <sys/types.h>
#include <libusb-1.0/libusb.h>
#include <stdlib.h>

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
    
    
    for(int i = 0; i < cnt; i++) {
        struct libusb_device_descriptor dev_desc;
        libusb_get_device_descriptor(devs[i],&dev_desc);
        
        if (dev_desc.bDeviceClass == 0) {
            libusb_device_handle* m_handle;
            m_handle = libusb_open_device_with_vid_pid(NULL, dev_desc.idVendor, dev_desc.idProduct);
            if (m_handle == NULL) {
                printf("Failed opening device\n");
                libusb_exit(NULL);
                return 1;
            }

            printf("Opened USB device successfully!\n");
            libusb_device* m_device = libusb_get_device(m_handle);
            struct libusb_device_descriptor m_device_descriptor;

            libusb_get_device_descriptor(m_device, &m_device_descriptor);
            printf("My device is connected on bus %d, port %d, with address %d\n", libusb_get_bus_number(m_device),
                    libusb_get_port_number(m_device),libusb_get_device_address(m_device));
            int config_num;
            return_value = libusb_get_configuration(m_handle,&config_num);
            struct libusb_config_descriptor* m_config_descriptors[1];
            libusb_get_config_descriptor_by_value(m_device, (uint8_t) config_num, (struct libusb_config_descriptor **) &m_config_descriptors);
            struct libusb_config_descriptor* m_config_descriptor = m_config_descriptors[0];
            
            for(int i = 0; i < m_config_descriptor->bNumInterfaces; i++) {
                libusb_claim_interface(m_handle,i);
                struct libusb_interface_descriptor m_interface_desc = m_config_descriptor->interface[i].altsetting[0];
                if (m_interface_desc.bInterfaceClass == 10) {
                    handle_usb_cdc_device(m_handle, m_device_descriptor.idVendor, m_device_descriptor.idProduct, m_interface_desc);
                } else if (m_interface_desc.bInterfaceClass == 8) {
                    handle_usb_mass_storage_device(m_device_descriptor.idVendor, m_device_descriptor.idProduct, m_interface_desc);
                } else {
                    printf("Device %x:%x is not a USB CDC or Mass Storage device\n",dev_desc.idVendor,dev_desc.idProduct);
                }
                libusb_release_interface(m_handle,i);
            }            

            libusb_close(m_handle);

        } else {
            printf("Device %x:%x is not a USB CDC or Mass Storage device\n",dev_desc.idVendor,dev_desc.idProduct);
        }
    }
    
    libusb_free_device_list(devs, 1);
    libusb_exit(NULL);
    return 0;
}

void handle_usb_cdc_device(struct libusb_device_handle* dev_handle, uint16_t vendor, uint16_t product, struct libusb_interface_descriptor interface_desc) {
    printf("The device %x:%x is a USB CDC device!\n", vendor, product);
    unsigned char strBuffer[256];
    libusb_get_string_descriptor(dev_handle,interface_desc.iInterface,0,strBuffer,256);
    printf("The current inteface is %s\n",strBuffer);
}

void handle_usb_mass_storage_device(uint16_t vendor, uint16_t product, struct libusb_interface_descriptor interface_desc) {
    printf("The device %x:%x is a USB Mass Storage device!\n", vendor, product);
}