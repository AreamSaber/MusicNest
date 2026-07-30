import { router } from '@kit.ArkUI';

/**
 * TopAppBar - 通用顶部导航栏
 * 支持：纯色模式 / 半透明玻璃态模式
 */
@Component
export struct TopAppBar {
  @Prop title: string = '鸿音管家';
  @Prop showBack: boolean = true;
  @Prop transparent: boolean = false;

  build() {
    Row() {
      // 左侧返回按钮
      if (this.showBack) {
        Button() {
          Text('←')
            .fontSize(22)
            .fontColor($r('app.color.primary'))
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .borderRadius(20)
        .onClick(() => {
          router.back();
        })
      } else {
        Row().width(40).height(40)
      }

      // 居中标题
      Text(this.title)
        .fontSize($r('app.float.headline_sm_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary'))
        .textAlign(TextAlign.Center)
        .layoutWeight(1)

      // 右侧占位
      Row().width(40).height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
    .backgroundColor(this.transparent ? 'rgba(249, 249, 255, 0.6)' : $r('app.color.surface'))
    .backdropBlur(this.transparent ? 8 : 0)
  }
}
