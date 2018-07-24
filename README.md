##########################################
##					##
##		接口说明		##
##					##
##########################################
1. 上传图片接口
http://127.0.0.1:8001/imgupload
1. 返回json接口
http://127.0.0.1:8001/json



##########################################
##					##
##		文件说明		##
##					##
##########################################
CHINESE-OCR/ 		源代码
ctpn_data/		样本集
docker/			dockerfile文件和相关脚本
testFlaskjosn.js	测试Flask服务开启后，客户端的json接收例子



##########################################
##					##
##		训练流程		##
##					##
##########################################

## 如果你想训练这个网络
### 1 对ctpn进行训练
* 定位到路径--./ctpn/ctpn/train_net.py
* 预训练的vgg网络路径[VGG_imagenet.npy](https://pan.baidu.com/s/1JO_ZojA5bkmJZsnxsShgkg)
将预训练权重下载下来，pretrained_model指向该路径即可,
此外整个模型的预训练权重[checkpoint](https://pan.baidu.com/s/1aT-vHgq7nvLy4M_T6SwR1Q)
* ctpn数据集[还是百度云](https://pan.baidu.com/s/1NXFmdP_OgRF42xfHXUhBHQ)
数据集下载完成并解压后，将.ctpn/lib/datasets/pascal_voc.py 文件中的pascal_voc 类中的参数self.devkit_path指向数据集的路径即可


1. push代码到master分支，创建git新分支idcar_branch

1. config 中修改
	__C.USE_GPU_NMS = True cpu则改为false

2. 在Pycharm右键CHINESE-OCR/ctpn -> Mark Directory as -> mark as resources root,解决不能引用下面包得问题
3. 在新分支上修改代码
1）/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/lib/datasets/pascal_voc.py
 （1）取消下面几行代码注释
	# cls_objs = [
        #     obj for obj in objs if obj.find('name').text in self._classes
        # ]
        # objs = cls_objs
 （2）修改如下训练数据集路径,/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/lib/fast_rcnn/config.py中
	#__C.DATA_DIR = '/Users/xiaofeng/Code/Github/dataset/CHINESE_OCR/ctpn/'
	改为
	__C.DATA_DIR = '/workspace/ctpn_data/VOCdevkit/'

2） /home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/ctpn/text.yml
	是否更改 “NCLASSES: 2” 后面分类数2
4. 备份model
	备份/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/save_model/ctpn_checkpoints

5. 训练
	
	1） 修改如下路径
		pretrained_model=
		'/Users/xiaofeng/Code/Github/dataset/CHINESE_OCR/ctpn/pretrain/VGG_imagenet.npy',
	    为
		注释掉(无预训练模型,模型在/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/save_model/ctpn_checkpoints)
	>> ./CHINESE-OCR_install_manager.sh
	>> cd /workspace/CHINESE-OCR/ctpn/ctpn
	>> python train_net.py


##########################################
##					##
##		ctpn样本制作		##
##					##
##########################################
1. 创建样本目录结构 
在/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/ctpn_data/VOCdevkit/VOC2007中创建如下文件夹
	Annotations\ 放xml
	ImageSets\
		Layout\
		Main\	放训练配置文件
		Segmentation\
	JPEGImages\ 放图片
2. JPEGImages\ 放图片,需要重命名为000005.jpg形式(图片必须为jpg格式)
执行  python ctpnImgNameTo000Style.py


import os
path = "/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/ctpn_data/VOCdevkit/VOC2007"
filelist = os.listdir(path) #该文件夹下所有的文件（包括文件夹）
count=0
for file in filelist:
    print(file)
for file in filelist:   #遍历所有文件
    Olddir=os.path.join(path,file)   #原来的文件路径
    if os.path.isdir(Olddir):   #如果是文件夹则跳过
	continue
    filename=os.path.splitext(file)[0]   #文件名
    filetype=os.path.splitext(file)[1]   #文件扩展名
    Newdir=os.path.join(path,str(count).zfill(6)+filetype)  #用字符串函数zfill 以0补全所需位数
    os.rename(Olddir,Newdir)#重命名
    count+=1

2. labelImg 标注自己的图片


3. ImageSets\Main里的四个txt文件
	test.txt是测试集
	train.txt是训练集
	val.txt是验证集
	trainval.txt是训练和验证集
	VOC2007中，trainval大概是整个数据集的50%，test也大概是整个数据集的50%；train大概是trainval的50%，val大概是trainval的50%。

根据已生成的xml，制作VOC2007数据集中的trainval.txt ； train.txt ； test.txt ； val.txt
trainval占总数据集的50%，test占总数据集的50%；train占trainval的50%，val占trainval的50%；
上面所占百分比可根据自己的数据集修改，如果数据集比较少，test和val可少一些

代码如下：

%注意修改下面四个值  
xmlfilepath='/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/ctpn_data/VOCdevkit/VOC2007/Annotations';  
txtsavepath='/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/ctpn_data/VOCdevkit/VOC2007/ImageSets/Main/';  
trainval_percent=0.5; #trainval占整个数据集的百分比，剩下部分就是test所占百分比  
train_percent=0.5; #train占trainval的百分比，剩下部分就是val所占百分比  

xmlfile=dir(xmlfilepath);  
numOfxml=length(xmlfile)-2;#减去.和..  总的数据集大小  

trainval=sort(randperm(numOfxml,floor(numOfxml*trainval_percent)));  
test=sort(setdiff(1:numOfxml,trainval));  

trainvalsize=length(trainval); #trainval的大小  
train=sort(trainval(randperm(trainvalsize,floor(trainvalsize*train_percent))));  
val=sort(setdiff(trainval,train));  

ftrainval=fopen([txtsavepath 'trainval.txt'],'w');  
ftest=fopen([txtsavepath 'test.txt'],'w');  
ftrain=fopen([txtsavepath 'train.txt'],'w');  
fval=fopen([txtsavepath 'val.txt'],'w');  

for i=1:numOfxml  
    if ismember(i,trainval)  
        fprintf(ftrainval,'%s\n',xmlfile(i+2).name(1:end-4));  
        if ismember(i,train)  
            fprintf(ftrain,'%s\n',xmlfile(i+2).name(1:end-4));  
        else  
            fprintf(fval,'%s\n',xmlfile(i+2).name(1:end-4));  
        end  
    else  
        fprintf(ftest,'%s\n',xmlfile(i+2).name(1:end-4));  
    end  
end  
fclose(ftrainval);  
fclose(ftrain);  
fclose(fval);  
fclose(ftest);



对应/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/ctpn_data/VOCdevkit/VOC2007(我们只有这个训练集),
VOC2012
VOC0712
对应/VOC2007/ImageSets/Main中'train.txt', 'val.txt', 'trainval.txt', 'test.txt'




需要配置路径位置：

/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/angle/predict.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/ctpn/model.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/ctpn/other.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/lib/fast_rcnn/config.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ocr/model.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/train/pytorch-train/crnn_main.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/lib/datasets/pascal_voc.py
/home/leo/PythonProjects/CHINESE-OCR/CHINESE-OCR_workspace/CHINESE-OCR/ctpn/ctpn/train_net.py









