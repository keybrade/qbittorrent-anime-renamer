# -*- coding: utf-8 -*-
import os

def rename_files(directory):
    prefixes_to_remove = ['[ANi]','[orion origin] ', '[orion origin]','[Nekomoe kissaten]']
    for root, dirs, files in os.walk(directory):
        for filename in files:
            original_filename = filename
            for prefix in prefixes_to_remove:
                if filename.startswith(prefix):
                    filename = filename.replace(prefix, '').replace('[Baha]', '').strip()
            if original_filename != filename:
                old_path = os.path.join(root, original_filename)
                new_path = os.path.join(root, filename)
                os.rename(old_path, new_path)
                print(f"重命名: {old_path} -> {new_path}")

# 获取当前目录
current_directory = os.getcwd()

# 调用函数重命名文件
rename_files(current_directory)

print("文件重命名完成。")
