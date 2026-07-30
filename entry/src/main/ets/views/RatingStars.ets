/**
 * RatingStars - 星级评分组件
 * 模式：readonly（只读展示）/ interactive（可点击评分）
 */
@Component
export struct RatingStars {
  @Prop rating: number = 0; // 1-5
  @Prop interactive: boolean = false;
  @Prop starSize: number = 40;
  onChange?: (rating: number) => void;

  build() {
    Row() {
      ForEach([1, 2, 3, 4, 5], (star: number) => {
        Text(star <= this.rating ? '★' : '☆')
          .fontSize(this.starSize)
          .fontColor(star <= this.rating ? '#FFB400' : $r('app.color.outline_variant'))
          .onClick(() => {
            if (this.interactive && this.onChange) {
              this.onChange(star);
            }
          })
      })
    }
    .justifyContent(FlexAlign.Center)
  }
}
