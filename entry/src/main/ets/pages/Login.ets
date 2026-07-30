import { router } from '@kit.ArkUI';
import { authService } from '../service/AuthService';
import { UserStore } from '../store/UserStore';

/**
 * Login - 登录页
 * 手机号验证码登录 + 华为账号一键登录
 */
@Entry
@Component
struct Login {
  @State phone: string = '';
  @State code: string = '';
  @State isSendingCode: boolean = false;
  @State countdown: number = 0;
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  private countdownTimer: number | null = null;

  aboutToAppear(): void {
    // 如果已登录，直接跳转首页
    if (UserStore.isLoggedIn()) {
      router.replaceUrl({ url: 'pages/MainPage' });
    }
  }

  aboutToDisappear(): void {
    if (this.countdownTimer !== null) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  }

  sendCode(): void {
    const phoneRegex = /^1[3-9]\d{9}$/;
    if (!phoneRegex.test(this.phone)) {
      this.errorMsg = '请输入正确的手机号';
      return;
    }
    this.isSendingCode = true;
    this.errorMsg = '';

    authService.sendCode(this.phone).then(() => {
      this.countdown = 60;
      this.countdownTimer = setInterval(() => {
        this.countdown--;
        if (this.countdown <= 0) {
          clearInterval(this.countdownTimer!);
          this.countdownTimer = null;
          this.isSendingCode = false;
        }
      }, 1000);
    }).catch(() => {
      this.errorMsg = '发送验证码失败，请稍后重试';
      this.isSendingCode = false;
    });
  }

  async login(): Promise<void> {
    if (!this.phone || !this.code) {
      this.errorMsg = '请输入手机号和验证码';
      return;
    }
    this.isLoading = true;
    this.errorMsg = '';

    try {
      const res = await authService.login(this.phone, this.code);
      if (res.code === 200) {
        router.replaceUrl({ url: 'pages/MainPage' });
      } else {
        this.errorMsg = res.message || '登录失败';
      }
    } catch (err) {
      this.errorMsg = '网络异常，请稍后重试';
    }
    this.isLoading = false;
  }

  huaweiLogin(): void {
    // TODO: 接入华为 Account Kit
    this.errorMsg = '华为账号登录将在后续版本接入';
  }

  build() {
    Column() {
      // 返回按钮
      Row() {
        Button() {
          Text('←')
            .fontSize(22)
            .fontColor($r('app.color.on_surface'))
        }
        .width(40).height(40)
        .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .margin({ top: 8 })

      // 标题
      Column() {
        Text('欢迎使用')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.on_surface'))

        Text('鸿音管家')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary'))
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .margin({ top: 40, bottom: 40 })

      // 手机号输入
      TextInput({ placeholder: '请输入手机号', text: this.phone })
        .type(InputType.Number)
        .maxLength(11)
        .fontSize($r('app.float.body_lg_font_size'))
        .height(52)
        .borderRadius(12)
        .backgroundColor($r('app.color.surface_container_lowest'))
        .onChange((value: string) => {
          this.phone = value;
          this.errorMsg = '';
        })

      // 验证码输入
      Row() {
        TextInput({ placeholder: '验证码', text: this.code })
          .type(InputType.Number)
          .maxLength(6)
          .fontSize($r('app.float.body_lg_font_size'))
          .height(52)
          .borderRadius(12)
          .backgroundColor($r('app.color.surface_container_lowest'))
          .layoutWeight(1)
          .onChange((value: string) => {
            this.code = value;
          })

        Button(this.isSendingCode && this.countdown > 0 ? this.countdown + 's' : '获取验证码')
          .fontSize($r('app.float.body_sm_font_size'))
          .fontColor(this.isSendingCode && this.countdown > 0 ? $r('app.color.on_surface_variant') : $r('app.color.primary'))
          .backgroundColor(this.isSendingCode && this.countdown > 0 ? $r('app.color.surface_variant') : 'rgba(46,2,233,0.08)')
          .borderRadius(12)
          .height(52)
          .width(110)
          .margin({ left: 12 })
          .enabled(!this.isSendingCode || this.countdown <= 0)
          .onClick(() => {
            this.sendCode();
          })
      }
      .margin({ top: 12 })

      // 错误信息
      if (this.errorMsg) {
        Text(this.errorMsg)
          .fontSize($r('app.float.body_sm_font_size'))
          .fontColor($r('app.color.error'))
          .margin({ top: 12 })
      }

      // 登录按钮
      Button() {
        Row() {
          if (this.isLoading) {
            LoadingProgress()
              .width(20).height(20)
              .color(Color.White)
          }
          Text('登录')
            .fontSize($r('app.float.body_lg_font_size'))
            .fontWeight(FontWeight.Bold)
            .margin({ left: this.isLoading ? 8 : 0 })
        }
      }
      .width('100%')
      .height(52)
      .borderRadius(12)
      .fontColor(Color.White)
      .linearGradient({
        angle: 135,
        colors: [['#4A3AFF', 0], ['#6B5CFF', 1]]
      })
      .margin({ top: 24 })
      .enabled(!this.isLoading)
      .onClick(() => {
        this.login();
      })

      // 分隔线
      Row() {
        Divider().layoutWeight(1).color($r('app.color.outline_variant'))
        Text(' 或 ')
          .fontSize($r('app.float.body_sm_font_size'))
          .fontColor($r('app.color.on_surface_variant'))
          .margin({ left: 8, right: 8 })
        Divider().layoutWeight(1).color($r('app.color.outline_variant'))
      }
      .margin({ top: 32, bottom: 24 })

      // 华为账号一键登录
      Button() {
        Row() {
          Text('🪷')
            .fontSize(24)
          Text('华为账号一键登录')
            .fontSize($r('app.float.body_md_font_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.on_surface'))
            .margin({ left: 8 })
        }
      }
      .width('100%')
      .height(52)
      .borderRadius(12)
      .backgroundColor($r('app.color.surface_container_lowest'))
      .border({ width: 1, color: $r('app.color.outline_variant') })
      .onClick(() => {
        this.huaweiLogin();
      })

      // 协议
      Text('登录即表示同意《用户协议》和《隐私政策》')
        .fontSize($r('app.float.label_sm_font_size'))
        .fontColor($r('app.color.outline'))
        .textAlign(TextAlign.Center)
        .width('100%')
        .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: $r('app.float.container_padding_mobile'), right: $r('app.float.container_padding_mobile') })
    .backgroundColor($r('app.color.background'))
  }
}
