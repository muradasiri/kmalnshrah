import 'package:flutter/material.dart';

class BalootRulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قوانين البلوت'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('قواعد أساسية'),
            _buildParagraph(
                'طريقة جلوس اللاعبين حيث كل لاعب يجلس أمام اللاعب الذي في فريقه.\n'
                    'تلعب جميع الأوراق في البلوت ما عدا الستة وما تحتها (الستة والخمسة والأربعة والثلاثة والاثنين) والجوكر.\n'
                    'يلعب في البلوت أربعة لاعبين، لاعبان ضد لاعبان، كل لاعب يجلس أمام اللاعب الذي في فريقه وعلى يمينه ويساره اللاعبان اللذان في الفريق الخصم.\n'
                    'نوع الورقة يسمى «الزات» وهي أربعة أنواع:\n'
                    'ديمن أو شوكت، هاص أو لال، سبيت أو كاله، شيريا أو كلفس\n'
                    'أما قيمة الورقة فهي كالتالي:\n'
                    'إكه أو خال، باش أو شايب، ميم أو بنت، غلام أو ولد، العشرة، التسعة، الثمانية، السبعة\n'
                    'من القوانين الشائعة في توزيع الأوراق، أن يطلب موزع الأوراق من اللاعب الذي على يساره إعادة ترتيب الأوراق لضمان عدم غشه.\n'
                    'تُوزع ثمانية أوراق لكل لاعب.\n'
                    'يعتبر أمراً ممنوعاً أن يكشف اللاعبين عن أوراقهم قبل رميها إلا في حالة كشف المشاريع.\n'
                    'تتكون اللعبة من طريقتين فقط: وهما الصن والحكم.\n'),
            _buildSectionTitle('طريقة اللعب'),
            _buildParagraph(
                'طريقة توزيع الأوراق\n'
                    'تبدأ اللعبة أولا بتوزيع الأوراق على جميع اللاعبين من قبل موزع الأوراق، وتكون طريقة التوزيع كالتالي:\n'
                    'يتم توزيع (3) ثلاث كروت لكل لاعب.\n'
                    'ثم عدد (2) كرت لكل لاعب.\n'
                    'يتم كشف كرت واحد في منتصف الطاولة ويتم البحث عن من يتعاقد معها ويسمى (المشتري).\n'
                    'بعد أن يشتري أحد اللاعبين الكرت الذي على الطاولة يتم توزيع 3 كروت لكل لاعب (باستثناء المشتري يوزع له كرتين ويعتبر الكرت الذي اشتراه هو الكرت الثالث).\n'
                    'بعد انتهاء التوزيع يكون لدى كل لاعب 8 كروت واللاعب الذي على يمين الموزع هو من يبدأ اللعب.\n'),
            _buildSectionTitle('طريقة الشراء'),
            _buildParagraph(
                'بعد أن يقوم الموزع بعملية توزيع خمسة كروت لكل لاعب والبحث عمن يشتري الكرت الذي على الطاولة يبدأ بقول (أول)، ثم ينتظر عمن يشتري الورقة التي على الطاولة وتبدأ العملية باللاعب الذي على يمين الموزع.\n'
                    'ويتم الشراء عن طريق إما الصن أو الحكم وتكون كالتالي:\n'
                    'في أول دوره يحق لكل لاعب شراء اللعب «صن» أو «حكم» ويجب أن يكون الحكم بنفس نوع الورقة المكشوفة على الطاولة.\n'
                    'الدورة الثانية يحق لكل لاعب شراء «صن» أو «حكم» على أن يكون الحكم أي نوع أو «زات» مخالف للورقة المكشوفة على الطاولة ويتم اختيار نوع الحكم من قبل المشتري.\n'
                    'في حال عدم الرغبة بالشراء فإن اللاعب يقول (بس) حسب اللهجة العامية.\n'
                    'كما يحق للموزع واللاعب الجالس على يساره (التشكيل) إذا أرادا ذلك.\n'
                    '(أشكل) ويسمح به للاعب الذي يقوم بتوزيع الورق واللاعب الذي على يساره فقط، وهو أن يعطي اللاعب الورقة في وسط الطاولة للاعب المقابل له وهو بنفس فريقه ويكون اللعب في هذه الحالة (صن) واللاعب الذي قام بعملية التشكيل هو نفسه اللاعب الشاري.\n'
                    'إن لم يتم شراء الورقة المكشوفة في الدورتين يعاد توزيع اللعب من اللاعب الآخر وتبدأ عملية توزيع ورق جديدة.\n'),
            _buildSectionTitle('ترتيب الصن'),
            _buildParagraph(
                '1 2 3 4 5 9 7 8\n'
                    'شيريا:\n'
                    'ديمن:\n'
                    'هاص:\n'
                    'سبيت:\n'),
            _buildSectionTitle('ترتيب الحكم'),
            _buildParagraph(
                'ويكون ترتيب الحكم فقط في «زات» الحكم الذي قام بشرائه المشتري وما عداه يكون ترتيبه صن، فلو افترضنا أن اللاعب قام بشراء حكم بورقة الشيريا، فإن الترتيب سيكون كالتالي:\n'
                    '1 2 3 4 5 6 7 8\n'
                    'شيريا:\n'),
            _buildSectionTitle('طريقة اللعب'),
            _buildParagraph(
                'بعد أن قام اللاعبين بالتوزيع والشراء يبدأ اللاعب الذي على يمين الموزع برمي الورقة الأولى ويرمي اللاعب الذي يليه وهكذا إلى أن يرموا اللاعبين الأربعة أوراقهم الأولى، وتكون أوراق الذي على الطاولة لأحد الفريقين بحسب القوانين الذي ذكرناها سابقا، وهكذا إلى أن تنتهي الدورة كاملة وترمى جميع الأوراق ويقوم اللاعبين بحساب أوراق كلا الفريقين وتحسب نقاط بحسب القوانين التي ستذكر فيما بعد، وتنتهي اللعبة بوصول أحد الفريقين لـ 152 نقطة.\n'
                    'يشترط لمن يشتري اللعب أحد الأوراق سواء في الحكم أو في الصن أن يحرز على الأقل ما يساوي نصف عدد النقاط المحتسبة لكل لعبة (أو طقه) إذا لم يستطع فتحتسب جميع النقاط للفريق الآخر.\n'),
            _buildSectionTitle('المشاريع'),
            _buildParagraph(
                'المشاريع هي عوامل مساعدة لكل فريق لرفع النقاط وهي تعتمد اعتمادا كليا على الحظ، ويتم اكتشاف المشاريع بعد توزيع الأوراق الثمانية، ويكشف الفريق صاحب المشروع الأكبر عن مشروعه بعد الدورة الأولى في حال كان هناك مشاريع للفريق المنافس.\n'
                    'ترتيب المشاريع يكون ترتيب المشاريع في هذه الطريقة فقط إذا كان في «زات» واحد عندما يكون المشروع عبارة عن أوراق مُتسلسلة (سرى، خمسين، مية).\n'
                    '1 2 3 4 5 6 7 8\n'
                    'الترتيب:\n'),
            _buildSectionTitle('أنواع المشاريع'),
            _buildParagraph(
                'الأربع مئة (400): وهي أن يكون لدى اللاعب أربع أوراق إكك أو خوال متشابهة بشرط أن يكون اللعب صن، أما إذا كان حكم فيكون المشروع مئة.\n'
                    'مئة (100): وتكون عبر طريقين:\n'
                    'أن يكون لدى اللاعب 5 أوراق متسلسلة بحسب ترتيب المشاريع التي ذُكرت في الأعلى.\n'
                    'أن يكون لدى اللاعب 4 أوراق من نوع شايب أو بنت أو ولد أو عشرة وكذلك 4 أوراق من نوع الإكك في الحكم فقط كما ذُكر سلفاً.\n'
                    'خمسين (50): وهي أن يكون لدى اللاعب 4 أوراق متسلسلة الترتيب.\n'
                    'سرى: وهي أن يكون لدى اللاعب 3 أوراق متسلسلة الترتيب.\n'
                    'بلوت: ويكون في الحكم فقط، وهي أن يلعب اللاعب شايب وبنت الحكم أو العكس على التوالي. ويُقصد بالتوالي بأن يُلعب الشايب والبنت عن طريق لاعب واحد شريطة أن لا يكونا ضمن مشروع المئة.\n'),
            _buildSectionTitle('ملاحظة'),
            _buildParagraph(
                'يكشف الفريق صاحب المشروع عن مشروعه بعد الدورة الأولى بعد أن يقوم بذكر مشروعه قبل أن يرمي الورقة الأولى، وفي حال كان هناك مشاريع للفريق المنافس فإن صاحب المشروع الأكبر هو الذي يقوم بكشف مشروعه، أما إذا تساوت مشاريع الفريقان فإنه ينظر إلى قيمة الأوراق وصاحب القيمة الأكبر هو من يقوم بكشف مشاريعه، فمثلا أحد لاعبي الفريق الأول لديه مشروع سرى (إكه ديمن، شايب ديمن، بنت ديمن) وأحد لاعبي الفريق الآخر لديه سرى أيضا (تسعة كلفس، ثمانية كلفس، سبعة كلفس)، فإن الفريق الأول هو الذي يقوم بكشف مشروعه لإن قيمة أوراقه أعلى، أما إذا تساوى الفريقان بنفس المشروع ونفس القيمة ولكن بأنواع أو «زاتات» مختلفة، فإن اللاعب الذي بدأ بالدور هو له الأحقية في كشف المشروع، وكما ذكرنا في حال تساوي المشاريع يجب على اللاعب الأول أن يسأل اللاعب المنافس صاحب المشروع المساوي له عن قيمة أوراقه فإن كانت أصغر أو تساويه كشف عن مشروعه، وإن كانت أكبر لم يكشف واللاعب المنافس هو الذي يقوم بكشف مشروعه.\n'),
            _buildSectionTitle('حساب اللعب'),
            _buildParagraph(
                'تتم عملية حساب النقاط من خلال الأوراق التي حصل عليها كلا الفريقان عن طريق:\n'
                    'الأكلات: وهي الأوراق التي حصل عليها الفريق ولكل ورقة معينة لها نقاط.\n'
                    'المشاريع: ولها حسبة خاصة.\n'
                    'الأرض (بالعامية «القاع»): وتكون للفريق صاحب الأكلة الأخيرة.\n'
                    'طريقة الحساب تُحتسب النقاط عن طريق جمع قيمة الأوراق التي حصل عليها كُل فريق، وتختلف في الصن والحكم:\n'
                    'في الصن: يكون الحساب بـ 26 نقطة.\n'
                    'في الحكم: يكون الحساب بـ 16 نقطة.\n'
                    'ملاحظة: يُشترط على الفريق المُشتري أن يُحرز على الأقل نصف النقاط وإلا فستُحتسب جميع النقاط للفريق الآخر، فمثلاً أحرز الفريق المُشتري اساس الصن؛ في هذه الحالة تُحتسب 26 نقطة للفريق الآخر ولا شيء للفريق المُشتري (ذلك لإن نصف 26 هو 13 والفريق المُشتري أحرز أقل من النصف).\n'),
            _buildSectionTitle('حساب الأوراق'),
            _buildParagraph(
                'الحساب في الصن تحسب الأوراق التالية في الصن كما يلي:\n'
                    'الورقة القيمة في الصن\n'
                    'إكه إحدى عشر نقطة (11)\n'
                    'عشرة عشرة نقاط (10)\n'
                    'شايب أربعة نقاط (4)\n'
                    'ولد نقطتان (2)\n'
                    'بنت ثلاثة نقاط (3)\n'
                    'تسعة ولا نقطة (0)\n'
                    'ثمانية ولا نقطة (0)\n'
                    'سبعة ولا نقطة (0)\n'
                    'الحساب في الحكم تحسب النقاط التالية فقط في زات الحكم ولنفترض أن الحكم هو كلفس فإن الحساب كالآتي وما عداه فإنه يحسب حساب الصن:\n'
                    'الورقة القيمة في الحكم\n'
                    'ولد عشرون نقطة (20)\n'
                    'تسعة أربعة عشر نقطة (14)\n'
                    'إكه إحدى عشر نقطة (11)\n'
                    'عشرة عشرة نقاط (10)\n'
                    'شايب أربعة نقاط (4)\n'
                    'بنت ثلاثة نقاط (3)\n'
                    'ثمانية ولا نقطة (0)\n'
                    'سبعة ولا نقطة (0)\n'),
            _buildSectionTitle('الدبل'),
            _buildParagraph(
                'الدبل وما يعرف بمضاعفة اللعب وهي من حق الفريق الذي لم يشتري، والهدف منها زيادة الأمل وإعطاء الفرصة للفريق الخاسر في الفوز إذا كان الفارق كبير بين الفريقان.\n'
                    'ويسمح الدبل بعد خروج اللعب (بمعنى بعد أن يتعدى القيد «النشرة» المائه) وهو يكون بمثابة إعطاء الفريق الخاسر فرصه للتعويض للحاق بالفريق الآخر.\n'
                    'الدبل: ويكون بمضاعفة قيمة اللعب (وهي من الحق الفريق اللذي لم يشتري)، مثال: في الصن 26+26=52.\n'
                    'دبل 3 «ثري» بالحكم فقط: يكون بمضاعفة قيمة اللعب 3 مرات (وهي من حق الفريق اللذي وقع عليه الدبل بأن يضاعف) مثال: 16+16+8 = 40.\n'
                    'دبل 4 «فور»: يكون بمضاعفة أربع مرات (وهي تحق للفريق الذي قام بعملية الدبل الأولى).\n'
                    'دبل اللعب «قهوه»: وهو دبل على مجموع نتيجة اللعب ومن يربح يربح اللعبة كلها (وهي تحق الفريق الذي من صالحه الدبل) وتكون في الحكم فقط.\n'
                    'ملاحظه: المشاريع في حالة حساب الدبل يتم دبل نتيجتها حسب قيمة الدبل أو الرهان بين الفريقين، سواء كان في الصن أو الحكم بإستثناء مشروع «البلوت» لايتم دبله في حساب اللعب.\n'),
            _buildSectionTitle('حساب المشاريع'),
            _buildParagraph(
                'في الصن:\n'
                    'السرا = 4 أبناط\n'
                    'الخمسين = 10 أبناط\n'
                    'المية = 20 بنط\n'
                    'الاربع مية = 40 بنط\n'
                    'في الحكم:\n'
                    'السرا = 2 بنطين\n'
                    'الخمسين =5 أبناط\n'
                    'المية = 10 أبناط\n'
                    'المية في الحكم إذا كانت 4 اكك = 10 أبناط\n'
                    'بلوت = 2 بنطين\n'),
            _buildSectionTitle('عملية الحساب'),
            _buildParagraph(
                'على الفريق الذي اشترى الورقة التي في الأرض أن يحرز نصف مجموع النقاط أو أعلى، في الصن مجموع النقاط هو 26 مع الأرض أي 260 بنط (ذلك لإن المجموع الأصلي هو 130 وفي الصن يتم المضاعفة فتكون 260)، وفي الحكم مجموع الأوراق هو 162 مع الأرض (في الحكم لا يتم مضاعفة النقاط)، مع العلم بأن حساب الأبناط يكون بهذه الطريقة:\n'
                    'أقل من خمسه يكسر للرقم الصحيح الأقرب له، مثال 34 = 3\n'
                    'أكثر من خمسه يجبر للرقم الصحيح الأقرب له، مثال 36 = 4\n'
                    'في العدد المناصف في الصن 35 = يتم مضاعفته ويكون 7 بمعنى (3.5 × 2 = 7)\n'
                    'في العدد المناصف في الحكم 45 = 4 بمعنى لا تجبر في العدد. لان الخصم يتحصل علي 117 فالاعدل ان يعطى ال1 لصاحب ال7 وليس لصاحب 5.\n'
                    'أمثلة\n'
                    'في الصن أحرز الفريق المشتري فقط 54 بنط من دون مشاريع أي أحرز 10 نقاط (5 × 2 = 10) وبالتالي لم يحرز العدد المطلوب وهو نصف المجموع في الصن وهو الرقم 13 وبالتالي يخسر الفريق الجولة وتُحسب جميع النقاط الـ 26 للفريق الآخر.\n'
                    'في الصن أحرز الفريق المشتري 95 نقطة من دون مشاريع، (95 × 2 = 190)، يحصل على 19 والفريق الآخر يحصل على 7 (26 - 19 = 7).\n'
                    'في الصن أحرز الفريق المشتري 60 بنط فقط ولديه مشروع خمسين. (60 × 2 = 120) ففي هذه الحالة لو قمنا بحساب ذلك من غير حساب المشاريع فسيظهر أن الفريق الذي اشترى الورقة خسر اللعبة لأنه أحرز 12 نقطة ولم يحرز نصف العدد أو أكثر وهو 13، لكن لو حسبنا مشروع الخمسين فسيكون المجموع هو 22 (12 + 10 = 22)، وبالتالي لم يخسر الفريق المشتري اللعبة وتكون النتيجة 22 للفريق المشتري و14 للفريق الآخر. (يُشترط أن يتساوى أو يتفوق مجموع أوراق ومشاريع الفريق المشتري على الفريق الآخر كي تنجح اللعبة).\n'
                    'في الحكم أحرز الفريق المشتري 45 بنط فقط ولديه مشروع سرى ومشروع بلوت. يكون المجموع الكلي هو 8 (4 + 2 + 2 = 8)، يخسر اللعبة وإن أحرز نصف العدد مع المشاريع لكنه لم يتفوق على الفريق الآخر الذي أحرز 12، وبالتالي تذهب جميع النقاط الـ 16 إلى الفريق الآخر وتكون النتيجة النهائية هي 20 للفريق الآخر ولا شيء للفريق المشتري (لإن مشاريع الفريق المشتري انتقلت إلى الفريق الآخر 16 + 2 «السرى» + 2 «البلوت» =20).\n'),
            _buildSectionTitle('ملاحظات'),
            _buildParagraph(
                'آخر أكله يكون حساب 10 نقاط للأرض.\n'
                    'يمنع للاعبين ان يظهروا أي اوراق كانت للاخرين.\n'
                    'في الحكم عندما يكون اللاعب الذي في فريقك يملك أكبر ورقه في أي «زات» (نوع من الاوراق) قبل أن يقوم بإنزالها يقول «اكه» لكي لا تأكل أنت بورق الحكم وتقوم برمي أي ورق آخر غير الحكم (أكبر ورقه في أي زات هي الاكه فأذا سقطت تصبح العشرة هي الأكة وهكذا عندما تسقط العشرة يصبح ما بعدها هو الاكه إلى السبعة حسب ترتيب الورق في الصن).\n'
                    'في حال الفريق الشاري للعب يكون لم يحصل على نصف مجموع الأبناط (النقاط) على الأقل، وإلا يعتبر خاسر ولا يحصل على أي نقطه.\n'
                    'الكبوت: وهو أن يستطيع فريق واحد جمع جميع الورق سواء في الحكم أو في الصن (تحسب له في الصن 44 مع مشاريعه وفي الحكم 25 مع مشاريعه).\n'
                    'الدبل:\n'
                    'في حالة الصن: إذا كان الفريق المشتري عدد ابناطه 100 أو اعلى والفريق الثاني اقل من 100 بنط، يكون للفريق الثاني حق التدبيل.\n'
                    'في حالة الحكم: يكون في أي وقت من اللعب عندما يشترى الورق الحكم.\n'
                    'في حالة تعادل النقاط في الدبل، تكون الخسارة على الفريق الذي قام بعملية الدبل (أو ثرٌى...الخ).\n'
                    'في حال الكبوت تحتسب مشاريع الفريق الذي «كبت» جميع الورق لصالحه، والمشاريع للفريق الآخر في الكبوت تكون بلا قيمه لأنه لم يستطع أن يأكل أي أكله من اللعب.\n'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BalootRulesPage(),
  ));
}
