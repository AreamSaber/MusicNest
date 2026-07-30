/**
 * InstrumentCard - 乐器卡片组件
 * 两种状态：可租 (available) / 已租出 (rented, 灰显)
 */
@Component
export struct InstrumentCard {
  @Prop instrumentName: string = '';
  @Prop category: string = '';
  @Prop brand: string = '';
  @Prop imageUrl: string = '';
  @Prop monthlyPrice: number = 0;
  @Prop rating: number = 0;
  @Prop status: string = 'available'; // available | rented | maintenance
  @Prop conditionLevel: number = 3; // 1-5

  private conditionLabels: string[] = ['全新', '95新', '9成新', '8成新', '较旧'];

  get isAvailable(): boolean {
    return this.status === 'available';
  }

  build() {
    Row() {
      // 左侧缩略图
      Stack() {
        Image(this.imageUrl || '')
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(8)
          .opacity(this.isAvailable ? 1.0 : 0.5)
          .saturate(this.isAvailable ? 1.0 : 0.3)

        // 已租出蒙层
        if (!this.isAvailable) {
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(8)
            .backgroundColor('rgba(255,255,255,0.5)')
            .justifyContent(FlexAlign.Center)

          Text('已租出')
            .fontSize($r('app.float.label_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))
            .fontWeight(FontWeight.Medium)
        }

        // 分类标签
        Text(this.category)
          .fontSize(10)
          .fontColor($r('app.color.primary'))
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .borderRadius(4)
          .backgroundColor('rgba(46, 2, 233, 0.05)')
          .position({ x: 8, y: 8 })
      }
      .width(112)
      .height(112)

      // 右侧信息
      Column() {
        // 名称
        Text(this.instrumentName)
          .fontSize($r('app.float.body_md_font_size'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isAvailable ? $r('app.color.on_surface') : $r('app.color.on_surface_variant'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 品牌 + 成色
        Row() {
          Text(this.brand)
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.on_surface_variant'))

          Text(' · ')
            .fontColor($r('app.color.outline_variant'))

          Text(this.conditionLabels[Math.max(0, Math.min(this.conditionLevel, 5) - 1)] || '')
            .fontSize($r('app.float.body_sm_font_size'))
            .fontColor($r('app.color.tertiary'))
        }
        .margin({ top: 4 })

        // 评分
        if (this.rating > 0) {
          Row() {
            Text('★')
              .fontSize(12)
              .fontColor('#FFB400')
            Text(this.rating.toFixed(1))
              .fontSize(12)
              .fontColor($r('app.color.on_surface_variant'))
              .margin({ left: 2 })
          }
          .margin({ top: 4 })
        }

        Blank()

        // 价格 + 状态
        Row() {
          Row() {
            Text('¥')
              .fontSize($r('app.float.body_sm_font_size'))
              .fontColor(this.isAvailable ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
            Text(this.monthlyPrice.toString())
              .fontSize($r('app.float.headline_sm_font_size'))
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isAvailable ? $r('app.color.primary') : $r('app.color.on_surface_variant'))
            Text('/月')
              .fontSize($r('app.float.label_sm_font_size'))
              .fontColor($r('app.color.on_surface_variant'))
          }

          Blank()

          Text(this.isAvailable ? '可租' : '已租出')
            .fontSize($r('app.float.label_sm_font_size'))
            .fontColor(this.isAvailable ? $r('app.color.tertiary') : $r('app.color.on_surface_variant'))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(4)
            .backgroundColor(this.isAvailable ? 'rgba(0, 83, 56, 0.1)' : $r('app.color.surface_variant'))
        }
        .width('100%')
      }
      .layoutWeight(1)
      .height(112)
      .margin({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('app.color.surface_container_lowest'))
    .shadow({
      radius: 20,
      color: 'rgba(30, 41, 59, 0.05)',
      offsetY: 4
    })
  }
}
