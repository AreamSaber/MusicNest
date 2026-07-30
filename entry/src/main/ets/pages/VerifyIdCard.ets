import { router } from '@kit.ArkUI';
import { TopAppBar } from '../views/TopAppBar';
import { ImagePicker } from '../views/ImagePicker';
import { userService } from '../service/UserService';

/**
 * VerifyIdCard - 实名认证页
 */
@Entry
@Component
struct VerifyIdCard {
  @State realName: string = '';
  @State idCard: string = '';
  @State frontImages: string[] = [];
  @State backImages: string[] = [];
  @State isLoading: boolean = false;

  async submit(): Promise<void> {
    if (!this.realName || this.realName.length < 2) return;
    const idRegex = /^\d{17}[\dXx]$/;
    if (!idRegex.test(this.idCard)) return;
    if (this.frontImages.length === 0 || this.backImages.length === 0) return;
    this.isLoading = true;
    try {
      await userService.submitVerification(this.realName, this.idCard, this.frontImages[0], this.backImages[0]);
      router.back();
    } catch (err) { console.error('Submit verification failed'); }
    this.isLoading = false;
  }

  build() {
    Column() {
      TopAppBar({ title: '实名认证', showBack: true })

      Scroll() {
        Column() {
          Text('为确保交易安全，请完成实名认证')
            .fontSize($r('app.float.body_sm_font_size')).fontColor($r('app.color.on_surface_variant')).width('100%').margin({ bottom: 24 })

          // 姓名
          TextInput({ placeholder: '请输入真实姓名', text: this.realName })
            .height(48).borderRadius(12).fontSize($r('app.float.body_md_font_size'))
            .backgroundColor($r('app.color.surface_container_lowest'))
            .onChange((v: string) => { this.realName = v; })

          // 身份证号
          TextInput({ placeholder: '请输入身份证号码', text: this.idCard })
            .type(InputType.Number).maxLength(18)
            .height(48).borderRadius(12).fontSize($r('app.float.body_md_font_size'))
            .backgroundColor($r('app.color.surface_container_lowest'))
            .margin({ top: 12 })
            .onChange((v: string) => { this.idCard = v; })

          // 身份证正面
          Column() {
            Text('身份证正面照')
              .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              .width('100%').margin({ top: 24, bottom: 8 })
            ImagePicker({ maxCount: 1, images: this.frontImages, onChange: (imgs: string[]) => { this.frontImages = imgs; } })
          }

          // 身份证反面
          Column() {
            Text('身份证反面照')
              .fontSize($r('app.float.headline_sm_font_size')).fontWeight(FontWeight.Bold)
              .width('100%').margin({ top: 24, bottom: 8 })
            ImagePicker({ maxCount: 1, images: this.backImages, onChange: (imgs: string[]) => { this.backImages = imgs; } })
          }

          Text('🔒 你的信息仅供实名认证使用，平台将严格保密')
            .fontSize($r('app.float.label_sm_font_size')).fontColor($r('app.color.outline'))
            .width('100%').margin({ top: 24 })

          Row().height(120)
        }
        .padding({ left: 16, right: 16 })
      }
      .layoutWeight(1).scrollBar(BarState.Off)

      Button('提交审核')
        .width('100%').height(52).borderRadius(14)
        .fontSize($r('app.float.body_lg_font_size')).fontWeight(FontWeight.Bold).fontColor(Color.White)
        .linearGradient({ angle: 135, colors: [['#4A3AFF', 0], ['#6B5CFF', 1]] })
        .margin(16)
        .enabled(this.realName.length >= 2 && /^\d{17}[\dXx]$/.test(this.idCard) && this.frontImages.length > 0 && this.backImages.length > 0 && !this.isLoading)
        .opacity(this.realName.length >= 2 && /^\d{17}[\dXx]$/.test(this.idCard) ? 1 : 0.5)
        .onClick(() => { this.submit(); })
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}
