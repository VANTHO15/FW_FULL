# tool
# Python 3.10: https://drive.google.com/file/d/1-PNdtbIVFUpo6pi8RJAGkovRW8Jz9U9S/view?usp=sharing
# Python 2.7: https://drive.google.com/file/d/1hlnuTKuHyM-AHsIiDquaN73abAq1s40B/view?usp=sharing
# Ozone Jlink: https://drive.google.com/file/d/1um2XMeeqVrluA7x6qWdEM6Fi-dvxP7P6/view?usp=sharing
# https://drive.google.com/file/d/1zUmQSWwDy1BDzhRutPvFbI3raQdl6tFV/view?usp=sharing
# Ozone Jlink Portable: https://drive.google.com/file/d/1izLmUuYhNdI24XyCv88GU8Kpki5jrcnp/view

B1: 
+ Vào UserConfig.py và config lai đường dẫn theo máy tính của mình 
+ pref_general.xdm chỉnh sửa lại version eb  : mặc định là 28.0
+ pref_general.xdm sử dụng module nào thì thêm module đó vào
+ Nếu generate mutil variant thì 
    - copy file systemmod/PostBuildVariantsSelectable.arxml ở eb tresos vào folder test/EbProject/systemmod
    - copy file config/SystemModel2.tdb ở eb tresos vào folder test/EbProject/config 
B2:
+ Vào cmd ở hàm main.py 
B3:
+ chạy các cmdline sau:
python main.py -o eb        : mở eb tresos lên, config và lấy config bỏ vào folder FW_HuLa\test\test_Gpio\Gpio_TS_001\config
python main.py -o clean     : clean output 
python main.py -o generate  : generate eb tresos
python main.py -o compile   : compile code 
python main.py -o debug     : debug bằng Ozone
python main.py -o nodebug   : run để lấy report
python main.py -o report    : chạy report ra file html
python main.py -o run       : download code
