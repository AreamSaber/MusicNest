import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * ImagePicker - 图片选择组件
 * 支持拍照/相册选取，网格预览，最多 maxCount 张
 */
@Component
export struct ImagePicker {
  @Prop maxCount: number = 5;
  @Prop @Watch('onImagesChange') images: Array<string> = [];
  onChange?: (images: Array<string>) => void;

  private onImagesChange(): void {
    if (this.onChange) {
      this.onChange(this.images);
    }
  }

  async pickImage(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = this.maxCount - this.images.length;

      const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      if (photoSelectResult.photoUris.length > 0) {
        const newImages = [...this.images, ...photoSelectResult.photoUris];
        this.images = newImages;
      }
    } catch (err) {
      const error = err as BusinessError;
      console.error('ImagePicker failed: ' + error.message);
    }
  }

  removeImage(index: number): void {
    const newImages = [...this.images];
    newImages.splice(index, 1);
    this.images = newImages;
  }

  build() {
    Column() {
      Row() {
        Text('照片上传')
          .fontSize($r('app.float.headline_sm_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_surface'))

        Blank()

        Text(this.images.length + '/' + this.maxCount + ' 张')
          .fontSize($r('app.float.body_sm_font_size'))
          .fontColor($r('app.color.on_surface_variant'))
      }
      .width('100%')

      Grid() {
        // 已选图片
        ForEach(this.images, (imageUri: string, index: number) => {
          GridItem() {
            Stack() {
              Image(imageUri)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(10)

              // 删除按钮
              Button() {
                Text('×')
                  .fontSize(16)
                  .fontColor(Color.White)
              }
              .width(24)
              .height(24)
              .backgroundColor('rgba(0,0,0,0.5)')
              .borderRadius(12)
              .position({ x: '100%', y: 0 })
              .translate({ x: -28, y: 4 })
              .onClick(() => {
                this.removeImage(index);
              })
            }
          }
        })

        // 添加按钮
        if (this.images.length < this.maxCount) {
          GridItem() {
            Column() {
              Text('📷')
                .fontSize(28)
              Text('添加照片')
                .fontSize($r('app.float.label_sm_font_size'))
                .fontColor($r('app.color.on_surface_variant'))
                .margin({ top: 4 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .border({ width: 1.5, color: $r('app.color.outline_variant'), style: BorderStyle.Dashed })
            .borderRadius(12)
            .backgroundColor($r('app.color.surface_container'))
            .onClick(() => {
              this.pickImage();
            })
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
      .margin({ top: 8 })

      Text('上传清晰的照片有助于我们更快定位问题')
        .fontSize($r('app.float.label_sm_font_size'))
        .fontColor($r('app.color.on_surface_variant'))
        .margin({ top: 8 })
    }
    .width('100%')
  }
}
