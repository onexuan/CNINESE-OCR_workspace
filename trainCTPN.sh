#!/bin/bash
# 预处理图片样本,制作xml,开始训练
echo '## 1. 删除ctpn_data中Annotations,ImageSets,JPEGImages文件夹'
cd /workspace/ctpn_data/VOCdevkit/VOC2007
rm -rf Annotations
rm -rf ImageSets
rm -rf JPEGImages

echo 'cd /workspace/CHINESE-OCR/ctpn/prepare_training_data'
cd /workspace/CHINESE-OCR/ctpn/prepare_training_data
rm -rf label_tmp
echo '## 2. 图片标注label/gt_000001.txt后,预处理图片,执行split_label.py'
python split_label.py

echo '## 3.更名原ctpn_data文件夹,执行ToVoc.py,生成压缩后图片,xml,和train.txt到ctpn_data下'

python ToVoc.py
echo '## 请查看ctpn_data文件夹'

echo '## 4. 训练ctpn'
cd /workspace/CHINESE-OCR/ctpn/output/ctpn_end2end/voc_2007_trainval/
mv /workspace/CHINESE-OCR/ctpn/output/ctpn_end2end/voc_2007_trainval /workspace/bak/voc_2007_trainval_`date +%Y%m%d_%H%M%S`
rm VGGnet_fast*
rm checkpoint
cd /workspace/CHINESE-OCR/ctpn/ctpn
python train_net.py
cd /workspace/CHINESE-OCR
python demo.py
