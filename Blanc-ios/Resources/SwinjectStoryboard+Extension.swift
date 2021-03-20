import CoreLocation
import Foundation
import Swinject
import SwinjectStoryboard
import SwinjectAutoregistration

extension ObjectScope {
    static let smsScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "sms scope."
    )
    static let smsConfirmScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "sms scope."
    )
}

extension ObjectScope {
    static let mainScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "main scope."
    )
}

extension ObjectScope {
    static let pendingScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "pending scope."
    )
}

extension ObjectScope {
    static let registrationScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "registration scope."
    )
}

extension ObjectScope {
    static let userSingleScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "user single scope."
    )
}

extension ObjectScope {
    static let postCreateScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "post create scope."
    )
    static let postSingleScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "post single scope."
    )
    static let postManagementScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "post management scope."
    )
    static let favoriteUserListScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "favorite user list scope."
    )
}

extension ObjectScope {
    static let conversationSingleScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "conversation single scope."
    )
}

extension ObjectScope {
    static let pushSettingScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "push setting scope."
    )

    static let myRatedScoreScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "my rated score scope."
    )

    static let avoidScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "avoid scope."
    )

    static let profileScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "profile scope."
    )

    static let paymentScope = ObjectScope(
        storageFactory: PermanentStorage.init, description: "payment scope"
    )

    static let accountManagement = ObjectScope(
        storageFactory: PermanentStorage.init, description: "account management scope."
    )
}


extension SwinjectStoryboard {
    class func setup() {
        Container.loggingFunction = nil
        registerDependencies()
        configInitView()
        configLoginView()
        configureRegistrationView()
        configSmsView()
        configConfirmModal()
        configMainViewControllers()
    }

    class func registerDependencies() {

        /** Root dependencies **/
        defaultContainer.autoregister(Preferences.self, initializer: Preferences.init).inObjectScope(.container)
        defaultContainer.autoregister(CLLocationManager.self, initializer: CLLocationManager.init).inObjectScope(.container)

        defaultContainer.autoregister(ReportService.self, initializer: ReportService.init).inObjectScope(.container)
        defaultContainer.autoregister(UserService.self, initializer: UserService.init).inObjectScope(.container)
        defaultContainer.autoregister(VerificationService.self, initializer: VerificationService.init).inObjectScope(.container)
        defaultContainer.autoregister(RequestService.self, initializer: RequestService.init).inObjectScope(.container)
        defaultContainer.autoregister(PostService.self, initializer: PostService.init).inObjectScope(.container)
        defaultContainer.autoregister(ConversationService.self, initializer: ConversationService.init).inObjectScope(.container)
        defaultContainer.autoregister(AlarmService.self, initializer: AlarmService.init).inObjectScope(.container)
        defaultContainer.autoregister(PaymentService.self, initializer: PaymentService.init).inObjectScope(.container)

        defaultContainer.register(Session.self) { resolver in
            let userService = resolver ~> UserService.self
            let preferences = resolver ~> Preferences.self
            return Session(userService: userService, preferences: preferences)
        }.inObjectScope(.container)
        defaultContainer.autoregister(Channel.self, initializer: Channel.init).inObjectScope(.container)

        defaultContainer.register(FcmTokenManager.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            return FcmTokenManager(session: session, userService: userService)
        }.inObjectScope(.container)

        /** Sms dependencies **/
        defaultContainer.register(SmsViewModel.self) { resolver in
            log.info("Creating SmsViewModel..")
            let verificationService = resolver ~> VerificationService.self
            return SmsViewModel(verificationService: verificationService)
        }.inObjectScope(.smsScope)
        defaultContainer.register(SmsConfirmViewModel.self) { resolver in
            log.info("Creating SmsConfirmViewModel..")
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let verificationService = resolver ~> VerificationService.self
            return SmsConfirmViewModel(
                session: session,
                userService: userService,
                verificationService: verificationService
            )
        }.inObjectScope(.smsConfirmScope)

        /** MainTabBar dependencies **/
        defaultContainer.register(MainTabBarViewModel.self) { resolver in
            log.info("Creating MainTabBarViewModel..")
            let conversationModel = resolver ~> ConversationModel.self
            return MainTabBarViewModel(conversationModel: conversationModel)
        }.inObjectScope(.mainScope)

        /** Home dependencies **/
        defaultContainer.register(HomeModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let requestService = resolver ~> RequestService.self
            let homeModel = HomeModel(
                session: session, userService: userService, requestService: requestService)
            return homeModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(HomeViewModel.self) { resolver in
            let channel = resolver ~> Channel.self
            let session = resolver ~> Session.self
            let homeModel = resolver ~> HomeModel.self
            let sendingModel = resolver ~> SendingModel.self
            let requestsModel = resolver ~> RequestsModel.self
            let conversationModel = resolver ~> ConversationModel.self
            let homeViewModel = HomeViewModel(
                session: session, channel: channel,
                homeModel: homeModel, sendingModel: sendingModel,
                requestsModel: requestsModel, conversationModel: conversationModel)
            return homeViewModel
        }.inObjectScope(.mainScope)

        /** Alarm dependencies **/
        defaultContainer.register(AlarmModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let postService = resolver ~> PostService.self
            let alarmService = resolver ~> AlarmService.self
            let alarmModel = AlarmModel(
                session: session, userService: userService, postService: postService, alarmService: alarmService)
            return alarmModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(AlarmViewModel.self) { resolver in
            let alarmModel = resolver ~> AlarmModel.self
            let alarmViewModel = AlarmViewModel(alarmModel: alarmModel)
            return alarmViewModel
        }.inObjectScope(.mainScope)

        /** RightSideBar dependencies **/
        defaultContainer.register(RightSideBarViewModel.self) { resolver in
            log.info("Creating RightSideBarViewModel..")
            let session = resolver ~> Session.self
            let alarmModel = resolver ~> AlarmModel.self
            let rightSideBarViewModel = RightSideBarViewModel(session: session, alarmModel: alarmModel)
            return rightSideBarViewModel
        }.inObjectScope(.mainScope)

        /** UserSingle dependencies **/
        defaultContainer.register(UserSingleModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let userService = resolver ~> UserService.self
            let requestService = resolver ~> RequestService.self
            let userSingleModel = UserSingleModel(
                session: session, channel: channel, userService: userService, requestService: requestService)
            return userSingleModel
        }.inObjectScope(.userSingleScope)
        defaultContainer.register(UserSingleViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let homeModel = resolver ~> HomeModel.self
            let userSingleModel = resolver ~> UserSingleModel.self
            let sendingModel = resolver ~> SendingModel.self
            let requestsModel = resolver ~> RequestsModel.self
            let conversationModel = resolver ~> ConversationModel.self
            let userSingleViewModel = UserSingleViewModel(
                session: session,
                homeModel: homeModel,
                userSingleModel: userSingleModel,
                sendingModel: sendingModel,
                requestsModel: requestsModel,
                conversationModel: conversationModel
            )
            return userSingleViewModel
        }.inObjectScope(.userSingleScope)

        /** Post dependencies **/
        defaultContainer.register(PostModel.self) { resolver in
            let session = resolver ~> Session.self
            let postService = resolver ~> PostService.self
            let postModel = PostModel(session: session, postService: postService)
            return postModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(PostViewModel.self) { resolver in
            let postModel = resolver ~> PostModel.self
            let session = resolver ~> Session.self
            let postViewModel = PostViewModel(postModel: postModel, session: session)
            return postViewModel
        }.inObjectScope(.mainScope)

        /** PostCreate dependencies **/
        defaultContainer.register(PostCreateModel.self) { resolver in
            let session: Session = resolver ~> Session.self
            let postService: PostService = resolver ~> PostService.self
            let postCreateModel = PostCreateModel(session: session, postService: postService)
            return postCreateModel
        }.inObjectScope(.postCreateScope)
        defaultContainer.register(PostCreateViewModel.self) { resolver in
            let postCreateModel = resolver ~> PostCreateModel.self
            let postCreateViewModel = PostCreateViewModel(postCreateModel: postCreateModel)
            return postCreateViewModel
        }.inObjectScope(.postCreateScope)

        /** PostSingle dependencies **/
        defaultContainer.register(PostSingleModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let postService = resolver ~> PostService.self
            let postSingleModel = PostSingleModel(session: session, channel: channel, postService: postService)
            return postSingleModel
        }.inObjectScope(.postSingleScope)
        defaultContainer.register(PostSingleViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let postSingleModel = resolver ~> PostSingleModel.self
            let postModel = resolver ~> PostModel.self
            let postSingleViewModel = PostSingleViewModel(
                session: session, postSingleModel: postSingleModel, postModel: postModel)
            return postSingleViewModel
        }.inObjectScope(.postSingleScope)

        /** PostManagement dependencies **/
        defaultContainer.register(PostManagementModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let postService = resolver ~> PostService.self
            let postSingleModel = PostManagementModel(
                session: session, userService: userService, postService: postService)
            return postSingleModel
        }.inObjectScope(.postManagementScope)
        defaultContainer.register(PostManagementViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let postManagementModel = resolver ~> PostManagementModel.self
            let postSingleModel = PostManagementViewModel(
                session: session, postManagementModel: postManagementModel)
            return postSingleModel
        }.inObjectScope(.postManagementScope)

        /** FavoriteUserList dependencies **/
        defaultContainer.register(FavoriteUserListModel.self) { resolver in
            let session: Session = resolver ~> Session.self
            let channel: Channel = resolver ~> Channel.self
            let userService: UserService = resolver ~> UserService.self
            let postService: PostService = resolver ~> PostService.self
            let favoriteUserListModel = FavoriteUserListModel(
                session: session, channel: channel, userService: userService, postService: postService)
            return favoriteUserListModel
        }.inObjectScope(.favoriteUserListScope)
        defaultContainer.register(FavoriteUserListViewModel.self) { resolver in
            let favoriteUserListModel = resolver ~> FavoriteUserListModel.self
            let favoriteUserListViewModel = FavoriteUserListViewModel(favoriteUserListModel: favoriteUserListModel)
            return favoriteUserListViewModel
        }.inObjectScope(.favoriteUserListScope)

        /** Requests dependencies **/
        defaultContainer.register(RequestsModel.self) { resolver in
            let session = resolver ~> Session.self
            let requestService = resolver ~> RequestService.self
            let requestsModel = RequestsModel(session: session, requestService: requestService)
            return requestsModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(RatedModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let ratedModel = RatedModel(session: session, userService: userService)
            return ratedModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(ReceivedViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let requestsModel = resolver ~> RequestsModel.self
            let ratedModel = resolver ~> RatedModel.self
            let conversationModel = resolver ~> ConversationModel.self
            let receivedViewModel = ReceivedViewModel(
                session: session,
                channel: channel,
                requestsModel: requestsModel,
                ratedModel: ratedModel,
                conversationModel: conversationModel
            )
            return receivedViewModel
        }.inObjectScope(.mainScope)

        /** Rating dependencies **/
        defaultContainer.register(SendingModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let userService = resolver ~> UserService.self
            let sendingModel = SendingModel(session: session, channel: channel, userService: userService)
            return sendingModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(SendingViewModel.self) { resolver in
            let sendingModel = resolver ~> SendingModel.self
            let ratingViewModel = SendingViewModel(sendingModel: sendingModel)
            return ratingViewModel
        }.inObjectScope(.mainScope)

        /** Conversation list dependencies **/
        defaultContainer.register(ConversationModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let conversationService = resolver ~> ConversationService.self
            let conversationModel = ConversationModel(session: session, channel: channel, conversationService: conversationService)
            return conversationModel
        }.inObjectScope(.mainScope)
        defaultContainer.register(ConversationViewModel.self) { resolver in
            let conversationModel = resolver ~> ConversationModel.self
            let conversationViewModel = ConversationViewModel(conversationModel: conversationModel)
            return conversationViewModel
        }.inObjectScope(.mainScope)

        /** Conversation single dependencies **/
        defaultContainer.register(ConversationSingleModel.self) { resolver in
            let session = resolver ~> Session.self
            let channel = resolver ~> Channel.self
            let conversationService = resolver ~> ConversationService.self
            let conversationSingleModel = ConversationSingleModel(
                session: session, channel: channel, conversationService: conversationService)
            return conversationSingleModel
        }.inObjectScope(.conversationSingleScope)
        defaultContainer.register(ConversationSingleViewModel.self) { resolver in
            let conversationSingleModel = resolver ~> ConversationSingleModel.self
            let conversationModel = resolver ~> ConversationModel.self
            let conversationSingleViewModel = ConversationSingleViewModel(
                conversationSingleModel: conversationSingleModel, conversationModel: conversationModel)
            return conversationSingleViewModel
        }.inObjectScope(.conversationSingleScope)

        /** Account dependencies **/
        defaultContainer.register(AccountViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let accountViewModel = AccountViewModel(session: session)
            return accountViewModel
        }.inObjectScope(.mainScope)

        /** Account dependencies **/
        defaultContainer.register(AccountManagementViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let accountManagementViewModel = AccountManagementViewModel(session: session, userService: userService)
            return accountManagementViewModel
        }.inObjectScope(.accountManagement)

        /** PushSetting dependencies **/
        defaultContainer.register(PushSettingModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let pushSettingModel = PushSettingModel(session: session, userService: userService)
            return pushSettingModel
        }.inObjectScope(.pushSettingScope)
        defaultContainer.register(PushSettingViewModel.self) { resolver in
            let pushSettingModel = resolver ~> PushSettingModel.self
            let pushSettingViewModel = PushSettingViewModel(pushSettingModel: pushSettingModel)
            return pushSettingViewModel
        }.inObjectScope(.pushSettingScope)

        /** MyRatedScore dependencies **/
        defaultContainer.register(MyRatedScoreModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let myRatedScoreModel = MyRatedScoreModel(session: session, userService: userService)
            return myRatedScoreModel
        }.inObjectScope(.myRatedScoreScope)
        defaultContainer.register(MyRatedScoreViewModel.self) { resolver in
            let myRatedScoreModel = resolver ~> MyRatedScoreModel.self
            let myRatedScoreViewModel = MyRatedScoreViewModel(myRatedScoreModel: myRatedScoreModel)
            return myRatedScoreViewModel
        }.inObjectScope(.myRatedScoreScope)

        /** Avoid dependencies **/
        defaultContainer.register(AvoidModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let avoidModel = AvoidModel(session: session, userService: userService)
            return avoidModel
        }.inObjectScope(.avoidScope)
        defaultContainer.register(AvoidViewModel.self) { resolver in
            let avoidModel = resolver ~> AvoidModel.self
            let avoidViewModel = AvoidViewModel(avoidModel: avoidModel)
            return avoidViewModel
        }.inObjectScope(.avoidScope)

        /** Pending dependencies **/
        defaultContainer.register(ImageViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let pendingModel = ImageViewModel(session: session, userService: userService)
            return pendingModel
        }.inObjectScope(.pendingScope)
        defaultContainer.register(ImageViewViewModel.self) { resolver in
            let pendingModel = resolver ~> ImageViewModel.self
            let pendingViewModel = ImageViewViewModel(pendingModel: pendingModel)
            return pendingViewModel
        }.inObjectScope(.pendingScope)

        /** Registration dependencies **/
        defaultContainer.register(RegistrationModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let registrationModel = RegistrationModel(session: session, userService: userService)
            return registrationModel
        }.inObjectScope(.registrationScope)
        defaultContainer.register(RegistrationViewModel.self) { resolver in
            let registrationModel = resolver ~> RegistrationModel.self
            let registrationViewModel = RegistrationViewModel(registrationModel: registrationModel)
            return registrationViewModel
        }.inObjectScope(.registrationScope)

        /** Profile dependencies **/
        defaultContainer.register(ProfileModel.self) { resolver in
            let session = resolver ~> Session.self
            let userService = resolver ~> UserService.self
            let profileModel = ProfileModel(session: session, userService: userService)
            return profileModel
        }.inObjectScope(.profileScope)
        defaultContainer.register(ProfileViewModel.self) { resolver in
            let profileModel = resolver ~> ProfileModel.self
            let profileViewModel = ProfileViewModel(profileModel: profileModel)
            return profileViewModel
        }.inObjectScope(.profileScope)

        /** InAppPurchase dependencies **/
        defaultContainer.register(InAppPurchaseModel.self) { resolver in
            let inAppPurchaseModel = InAppPurchaseModel()
            return inAppPurchaseModel
        }.inObjectScope(.paymentScope)
        defaultContainer.register(InAppPurchaseViewModel.self) { resolver in
            let session = resolver ~> Session.self
            let paymentService = resolver ~> PaymentService.self
            let inAppPurchaseModel = resolver ~> InAppPurchaseModel.self
            let inAppPurchaseViewModel = InAppPurchaseViewModel(
                session: session, paymentService: paymentService, inAppPurchaseModel: inAppPurchaseModel)
            return inAppPurchaseViewModel
        }.inObjectScope(.paymentScope)
    }

    class func configInitView() {
        defaultContainer.storyboardInitCompleted(InitPagerViewController.self) { resolver, controller in
            log.info("Injecting dependencies into InitPagerViewController")
            controller.userService = resolver ~> UserService.self
            controller.session = resolver ~> Session.self
        }
    }

    class func configLoginView() {
        defaultContainer.storyboardInitCompleted(LoginViewController.self) { resolver, controller in
            log.info("Injecting dependencies into LoginViewController")
            controller.userService = resolver ~> UserService.self
            controller.session = resolver ~> Session.self
        }
    }

    class func configureRegistrationView() {

        defaultContainer.storyboardInitCompleted(RegistrationNavigationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationNavigationViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationRootViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationRootViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationNicknameViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationNicknameViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationSexViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationSexViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationBirthdayViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationBirthdayViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationHeightViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationHeightViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationBodyTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationBodyTypeViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationOccupationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationOccupationViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationEducationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationEducationViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationReligionViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationReligionViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationDrinkViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationDrinkViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationSmokingViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationSmokingViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationBloodTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationBloodTypeViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationIntroductionViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationIntroductionViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationCharmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationCharmViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationIdealTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationIdealTypeViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationInterestsViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationInterestsViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationImageViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationImageViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(RegistrationPendingViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RegistrationPendingViewController")
            controller.registrationViewModel = resolver ~> RegistrationViewModel.self
        }
    }

    class func configSmsView() {
        defaultContainer.storyboardInitCompleted(SmsViewController.self) { resolver, controller in
            log.info("Injecting dependencies into SmsViewController")
            controller.smsViewModel = resolver ~> SmsViewModel.self
        }
        defaultContainer.storyboardInitCompleted(SmsConfirmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into SmsConfirmViewController")
            controller.smsConfirmViewModel = resolver ~> SmsConfirmViewModel.self
        }
    }

    class func configConfirmModal() {
        defaultContainer.storyboardInitCompleted(RequestConfirmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RequestConfirmViewController")
            controller.session = resolver ~> Session.self
        }
        defaultContainer.storyboardInitCompleted(OpenConversationConfirmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into OpenConversationConfirmViewController")
            controller.session = resolver ~> Session.self
        }
    }

    class func configMainViewControllers() {

        defaultContainer.storyboardInitCompleted(MainTabBarController.self) { resolver, controller in
            log.info("Injecting dependencies into MainTabBarController")
            controller.mainTabBarViewModel = resolver ~> MainTabBarViewModel.self
        }

        defaultContainer.storyboardInitCompleted(HomeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into HomeViewController")
            let rightSideBarViewModel = resolver ~> RightSideBarViewModel.self
            controller.rightSideBarView = RightSideBarView(rightSideBarViewModel: rightSideBarViewModel)
            controller.homeViewModel = resolver ~> HomeViewModel.self
        }

        defaultContainer.storyboardInitCompleted(AlarmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into AlarmViewController")
            controller.channel = resolver ~> Channel.self
            controller.alarmViewModel = resolver ~> AlarmViewModel.self
        }

        defaultContainer.storyboardInitCompleted(UserSingleViewController.self) { resolver, controller in
            log.info("Injecting dependencies into UserSingleViewController")
            controller.userSingleViewModel = resolver ~> UserSingleViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PostViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PostViewController")
            controller.postViewModel = resolver ~> PostViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PostListViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PostListViewController")
            controller.channel = resolver ~> Channel.self
            controller.postViewModel = resolver ~> PostViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PostCreateViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PostCreateViewController")
            controller.postCreateViewModel = resolver ~> PostCreateViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PostSingleViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PostSingleViewController")
            controller.session = resolver ~> Session.self
            controller.postSingleViewModel = resolver ~> PostSingleViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PostManagementViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PostManagementViewController")
            controller.channel = resolver ~> Channel.self
            controller.session = resolver ~> Session.self
            controller.postManagementViewModel = resolver ~> PostManagementViewModel.self
        }

        defaultContainer.storyboardInitCompleted(PagerViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PagerViewController")
            let rightSideBarViewModel = resolver ~> RightSideBarViewModel.self
            controller.rightSideBarView = RightSideBarView(rightSideBarViewModel: rightSideBarViewModel)
        }

        defaultContainer.storyboardInitCompleted(FavoriteUserListViewController.self) { resolver, controller in
            log.info("Injecting dependencies into FavoriteUserListViewController")
            controller.favoriteUserListViewModel = resolver ~> FavoriteUserListViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ReceivedViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RequestsViewController")
            controller.receivedViewModel = resolver ~> ReceivedViewModel.self
        }

        defaultContainer.storyboardInitCompleted(SendingViewController.self) { resolver, controller in
            log.info("Injecting dependencies into RatingViewController")
            controller.sendingViewModel = resolver ~> SendingViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ConversationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ConversationViewController")
            let rightSideBarViewModel = resolver ~> RightSideBarViewModel.self
            controller.rightSideBarView = RightSideBarView(rightSideBarViewModel: rightSideBarViewModel)
            controller.conversationViewModel = resolver ~> ConversationViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ConversationSingleViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ConversationSingleViewController")
            controller.conversationSingleViewModel = resolver ~> ConversationSingleViewModel.self
        }

        defaultContainer.storyboardInitCompleted(AccountViewController.self) { resolver, controller in
            log.info("Injecting dependencies into AccountViewController")
            controller.accountViewModel = resolver ~> AccountViewModel.self
        }

        defaultContainer.storyboardInitCompleted(AccountManagementViewController.self) { resolver, controller in
            log.info("Injecting dependencies into AccountManagementViewController")
            controller.accountManagementViewModel = resolver ~> AccountManagementViewModel.self
        }

        defaultContainer.storyboardInitCompleted(InAppPurchaseViewController.self) { resolver, controller in
            log.info("Injecting dependencies into InAppPurchaseViewController")
            let inAppPurchaseViewModel = resolver ~> InAppPurchaseViewModel.self
            let rightSideBarViewModel = resolver ~> RightSideBarViewModel.self
            controller.rightSideBarView = RightSideBarView(rightSideBarViewModel: rightSideBarViewModel)
            controller.inAppPurchaseViewModel = inAppPurchaseViewModel
        }

        defaultContainer.storyboardInitCompleted(ReportViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ReportViewController")
            let reportService = resolver ~> ReportService.self
            let reportViewModel = ReportViewModel(reportService: reportService)
            controller.reportViewModel = reportViewModel
        }

        defaultContainer.storyboardInitCompleted(PushSettingViewController.self) { resolver, controller in
            log.info("Injecting dependencies into PushSettingViewController")
            controller.pushSettingViewModel = resolver ~> PushSettingViewModel.self
        }

        defaultContainer.storyboardInitCompleted(MyRatedScoreViewController.self) { resolver, controller in
            log.info("Injecting dependencies into MyRatedScoreViewController")
            controller.myRatedScoreViewModel = resolver ~> MyRatedScoreViewModel.self
        }

        defaultContainer.storyboardInitCompleted(AvoidViewController.self) { resolver, controller in
            log.info("Injecting dependencies into AvoidViewController")
            controller.avoidViewModel = resolver ~> AvoidViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ProfileViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ProfileViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ImageViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ImageViewController")
            controller.pendingViewModel = resolver ~> ImageViewViewModel.self
        }

        defaultContainer.storyboardInitCompleted(NicknameViewController.self) { resolver, controller in
            log.info("Injecting dependencies into NicknameViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(SexViewController.self) { resolver, controller in
            log.info("Injecting dependencies into SexViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(BirthdayViewController.self) { resolver, controller in
            log.info("Injecting dependencies into BirthdayViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(HeightViewController.self) { resolver, controller in
            log.info("Injecting dependencies into HeightViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(BodyTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into BodyTypeViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(OccupationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into OccupationViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(EducationViewController.self) { resolver, controller in
            log.info("Injecting dependencies into EducationViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(ReligionViewController.self) { resolver, controller in
            log.info("Injecting dependencies into ReligionViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(DrinkViewController.self) { resolver, controller in
            log.info("Injecting dependencies into DrinkViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(SmokingViewController.self) { resolver, controller in
            log.info("Injecting dependencies into SmokingViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(BloodTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into BloodTypeViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(IntroductionViewController.self) { resolver, controller in
            log.info("Injecting dependencies into IntroductionViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(CharmViewController.self) { resolver, controller in
            log.info("Injecting dependencies into CharmViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(IdealTypeViewController.self) { resolver, controller in
            log.info("Injecting dependencies into IdealTypeViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }

        defaultContainer.storyboardInitCompleted(InterestsViewController.self) { resolver, controller in
            log.info("Injecting dependencies into InterestsViewController")
            controller.profileViewModel = resolver ~> ProfileViewModel.self
        }
    }
}
