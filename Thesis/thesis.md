# Το περιβάλλον Julia: Μελέτη, αξιολόγηση και εφαρμογές

## Abstract

-------------
CHAPTERS

-------------

# Περιγραφή Julia στόχοι

# Implementation Sparse σε Julia

# Parallel σε Julia (+ συγκεκριμένα για το BFBCG)

# Πειραματικά Αποτελέσματα

--------------------

## Περιγραφή της γλώσσας προγραμματισμού Julia

Η Julia είναι μια γλώσσα υψηλού επιπέδου, δυναμικού συστήματος τύπων, πολλαπλών προγραμματιστικών μοντέλων. Στοχεύει σε τομείς όπως: αριθμητική ανάλυση, επιστήμη υπολογισμού, γνωσιακή μάθηση, ενώ είναι κατάλληλη και για γενικού σκοπού προγραμματισμό.


Εστιάζοντας στην παροχή του δυναμικού συστήματος τύπων της Ruby, την απλότητα του συντακτικού της Python και την απόδοση της C, η Julia μπορεί να αποδειχτεί η ιδανική γλώσσα για προγραμματισμό υψηλής επίδοσης, αλλά και ένα αναντικατάστατο εργαλείο για την έρευνα σε επιστημονικά και εφαρμοσμένα πεδία.

Η Julia δημοσιεύεται υπό την άδεια MIT, και κατά συνέπεια είναι δωρεάν και ελεύθερο λογισιμικό / ανοιχτού κώδικα.

#### Επισκόπηση χαρακτηριστικών

Η Julia είναι μεταγλωτισμένη τη-στιγμή-που-χρειάζεται (JIT-compiled), με συλλογή σκουπιδιών (garbage collected), ενώ χρησιμοποιεί πολλαπλή επιστολή (multiple dispatch). Σχεδιάστηκε με στόχο την υψηλή απόδοση, καταφέρνοντας να είναι συγκρίσιμη με πολύ χαμηλότερου επιπέδου γλώσσες όπως η C. Επιπροσθέτως έχει ληφθεί ειδική μέριμνα, ώστε η παράλληλη επεξεργασία και ο κατανεμημένος υπολογισμός να εξυπηρετούνται σε άριστο βαθμό. Άλλα συστατικά-κλειδιά είναι η υποστήριξη μεταπρογραμματισμού (metaprogramming), ενσωματωμένος διαχειριστής πακέτων / βιβλιοθηκών, εξαιρετικά εύκολη διεπαφή με τις C και Fortran καθώς και ένας εκλεπτυσμένος μεταγλωτιστής, ικανός να παράγει εξειδικευμένο κώδικα ανάλογο των δεδομένων.

#### Ιστορική αναδρομή

Σχεδιασμένη από τους Viral B. Shah, Jeff Bezanson, Stefan Karpinski και Alan Edelman, με την πρώτη επίσημη κυκλοφορία το 2015, αφότου είχε αποκαλυφθεί την ημέρα του Αγίου Βαλεντίνου το 2012. Η δημοφιλία της γλώσσας έχει εκτοξευθεί, θέτοντάς την στις πλέον ανερχόμενες γλώσσες προγραμματισμού σε διάφορους δείκτες, όπως το TIOBE Programming Community Index (www.tiobe.com) και τις πλέον αγαπητές και επιθυμητές γλώσσες σε πολλές ετήσιες έρευνες του Stack Overflow. Το πλήθος των χρηστών της συνεχίζει να αυξάνει εκθετικά, με πάνω από τρία εκατομμύρια χρήστες το 2019.

#### Το πρόβλημα των δύο γλωσσών

Julia's design, came as an answer to the two languages problem, faced by modern data scientists; Writing a code prototype in a dynamically typed language, to verify a working solution, but then having to rewrite a whole new implementation in another, statically typed language in order to achieve acceptable performance.

One can easily implement some algorithm or conceptual solution in Julia. Its great advantage in comparison to languages like Python, is that the very same code, can achieve the performance of highly optimized, machine specific code (thanks to LLVM), only by introducing very minor changes, in the form of type declaration for a method's arguments. This makes the code extremely easy to optimize, even for users with little understanding of low level architecture.

This is achieved, thanks to Julia's versatile and advanced compiler, that can produce LLVM IR (intermediate representation), specialized on the types of the parameters of each calculation. If the types are not known in advance, the generated assembly may not make any assumptions about the arguments' memory representation, and while perfectly working, it is sub optimal. In case that constraints are enforced on the types, the compiler is smart enough, to take advantage of them, and generate assembly similar to that of the statically typed C. As a result, you have all of the benefits of a statically typed language, both in type safety and performance, as an opt in feature, allowing the liberty and ease of use of a dynamic type system wherever speed is not a concern.

### Platforms

Julia is JIT-compiled with an LLVM backend. It can generate native code for all of the major modern platforms:

* Windows
* Linux
* Mac OS
* FreeBSD

The main architectures supported are x86-64 (AMD64) and x86, while there is experimental support for  ARM, AARCH64, and POWER (little-endian).

### Language Features in depth

#### Type System

Julia features a dynamic, nominative and parametric type system. Every type is abstract, except concrete types, which are final. This means that the only types that can be instantiated, are unable to have subtypes, while their supertypes cannot be instantiated. That distinction from other object oriented languages' type systems, implies that inheritable types are only used to infer common behavior, not implementation details such as data (much like interfaces in other OO programming languages); Only the types which are at the bottom of the type tree, can have implementations and specific memory representation.

As the type system is dynamic, usually it is not necessary to explicitly declare types. Variables are just a way to name (or reference) data, and do not have types, only the values that they can hold have types. As a result of those two points, most programs do not need to declare any type information, leading to adaptable code, that can behave robustly, no matter the input.

#### Multiple Dispatch

##### Short introduction to multiple dispatch

Possibly the most attractive feature of Julia, is multiple dispatch, the ability to dispatch a function, based on all of its parameters.

Multiple dispatch, is a generalization of single-dispatch polymorphism, present in most object oriented programming languages.

Commonly, object oriented languages, have a feature called subtyping (usually implemented through inheritance), where one parameter type, can be substituted by its subtypes, types that are more specific and lower in the type hierarchy tree. In every function call, the specific function that will be executed, is selected based on the type of one of the arguments (most commonly the first one):

```C
objectOfTypeA.method()
```

The above, in languages like C++, C#, Java, etc., assumes the existence of a function named `method`, which implies an argument of some type, named `objectOfTypeA`. The same identifier, `method`, can also exist in other types, or even subtypes of the aforementioned object's class. Thus, in order to differentiate them, the type of the object "calling" the method, is of significance; this is usually implemented as the first argument of a function like so:

```C
method(A parameter1)
```

(where A is the type of the first parameter), in C like code. That is how a function is dispatched (its code is selected for execution), in single dispatch languages.

In contrast to that, multiple dispatch languages, do not have any significant parameters, whose types are treated differently; They are dispatched based on the derived type of every argument. For example:

```C
method (T_1 parameter1, T_2 parameter2)
```

```C
method (T_1 parameter1, T_3 parameter2)
```

Those two methods, are different, even though they have the same name, as the type of their second parameter is T_2 and T_3 respectively. If one would call those methods in the following way:

```C
method (object1, object2)
```

The type of object 2 must be determined in order to decide which method to route this statement to. If object 2 is of type T_2, the first method will be dispatched. In the special case where T_3 is a subtype of T_2, if the object is of type T_3, the second method will be selected, as it is more specific. This is something that can only occur for a special argument in single dispatch languages, while in multiple dispatch, any number of arguments enjoys the same polymorphism.

##### Method calls in Julia

Given the following call:

```Julia
method(argument1, argument2)
```

The existence of a method named `method` is assumed, whose return type is `T`, and takes two arguments, of types `T1` and `T2`, named `argument1` and `argument2` respectively.

According to the Julia spec, every function, is a member of a certain type; This is the return type of the function, in our example `T`. Type T, has a method table, which contains all the functions associated with it.

When the JIT compiler encounters that statement, it will dispatch a method through the following algorithm:

1. Determine the associated type with `method`, as `T`
2. Lookup in the function table of `T`, for a method with that name (`method` in the example)
3. Select the one who has two parameters of types `T1` and `T2`

The compiler, will generate specific code, only for those three aforementioned types, if it doesn't already exist. In case that we call the same method with a new argument:

```Julia
method(argument1, argument3::T3)
```

of type `T3`, unrelated to `T2`, the previous method, is not applicable, therefore a new one will be dispatched (and compiled if needed).

In the case where the argument types are not specified -as Julia is a dynamically typed language and does not require type declaration-, and no assertion can be inferred about the runtime types, multiple dispatch cannot be utilized, because only one method can be generated, that can make no assumptions about its arguments. The generated assembly is much less efficient, as many precautions must be taken for memory access, since the types are uncertain, and their size is unknown, as well as them being values or references to values.

#### Παράλληλη Επεξεργασία και Κατανεμημένος Υπολογισμός

#### Γραμμική Άλγεβρα

Η Julia παρέχει υλοποιήσεις των περισσότερων χρήσιμων και συχνών υπολογισμών γραμμικής άλγεβρας, ανάμεσα στις οποίες, ο υπολογισμός ιδιοτιμών και ιδιοδιανυσμάτων, διάφορες παραγοντοποιήσεις, αντιστροφή μητρώου και άλλες. Σε αυτό το κεφάλαιο θα μελετήσουμε ορισμένες συμπεριφορές και θα αξιολογήσουμε την εγγενή υλοποίηση των μαθηματικών διαδικασιών.



### Βελτιστοποίηση κώδικα Julia

#### Ανάλυση Επιδόσεων (Profiling)



# Benchmarking και Χρονομέτρηση Κώδικα

## `@time`
Για να μετρήσουμε τις επιδόσεις του κώδικά μας, σε επίπεδο χρόνου, χρησιμοποιούμε το macro `@time`.

**Προσοχή:** Η Julia, όπως και οι περισσότερες JIT-compiled γλώσσες, θα μεταγλωττίσουν/παράγουν ενδιάμεσο κώδικα (bytecode) οποιαδήποτε συνάρτηση/μέθοδο, την πρώτη φορά που καλείται. Αυτό σημαίνει, πως την πρώτη φορά που καλούμε μια συνάρτηση που γράψαμε, θα πρέπει να περιμένουμε να μεταγλωττιστεί. Γι' αυτό, **δεν χρονομετρούμε την 1η κλήση**.

*Προσέξτε ότι, το παραπάνω ισχύει για τα πάντα, ακόμα και ενσωματωμένες συναρτήσεις της Julia base library ή macros. Δηλαδή, ακόμα και το `@time` την πρώτη φορά που θα κληθεί πρέπει να μεταγλωττιστεί.*

```julia
function f(n::Number)
  for i = 0:100000
    n = n+1
  end
  n
end

@time f(3)

@time f(3)
```
```julia
0.003120 seconds (1.36 k allocations: 63.282 KB)
0.000002 seconds (5 allocations: 176 bytes)
```

*Όπως βλέπετε, στην 1η κλήση έχουμε δραματικά περισσότερο χρόνο εκτέλεσης*

## `tic()` `toc()` και `@elapsed`

Στη Julia υπάρχουν και οι συναρτήσεις `tic()` και `toc()` (όπως και στη Matlab). Επίσης υπάρχει και το macro `@elapsed` που μετρά το χρόνο εκτέλεσης. Η κύρια διαφορά τους με το `@time` είναι πως το δεύτερο, μας παρέχει και πληροφορίες για το memory allocation *(επίσης το `@time` επιστρέφει και το αποτέλεσμα που υπολόγισε)*. Αυτό είναι πολύ χρήσιμο για να καταλάβουμε εύκολα αν ο κώδικάς μας έχει κάποιο σημείο που επιδέχεται βελτιστοποίησης. Στην πραγματικότητα, δεν έχουν διαφορά στη χρονομέτρηση, απλά το `@time` είναι πιο χρήσιμο.


# Αναπάντεχες Συμπεριφορές

## Μοναδιαίος τελεστής -


```julia
function Oops()
  vectorRow = [4 - 3 5]
  vectorColumn = [8 -1 12]'
  vectorColumn * vectorRow
end
Oops()
```

Μετά την εκτέλεση αυτής της μεθόδου, είναι πολύ πιθανό να αναμέναμε το αποτέλεσμα να είναι ένα δύο επί δύο μητρώο (2x2 Array). Ωστόσο, αυτό που παίρνουμε, είναι ένα μητρώο 3x2!

Αυτό συμβαίνει, γιατί η Julia, αντίθετα με γνωστές C-like γλώσσες, τα κενά δεν αγνοούνται. Παραδείγματος χάρη, το κενό σημαίνει το επόμενο στοιχείο ενός διανύσματος/μητρώου. Στη συγκεκριμένη περίπτωση, το vectorRow είναι ένα διάνυσμα γραμμή, με 2 στοιχεία, μιας και το "-" είναι ο δυαδικός τελεστής αφαίρεσης. Στο vectorColumn όμως, επειδή δεν μεσολαβεί κενό μεταξύ του τελεστή και του αριθμού 1, ο τελεστής θεωρείται ως μοναδιαίος. Αυτό οδηγεί στο να εκληφθεί το "-1" ως ένα όρισμα κατά την αρχικοποίηση του διανύσματος, και όχι ως μέρος μιας έκφρασης προς evaluation (όπως η έκφραση "4 - 3" στο προηγούμενο διάνυσμα). Έτσι έχουμε ένα διάνυσμα τρία επί ένα (3x1), αντί του αναμενόμενου δύο επί ένα, και το αποτέλεσμα του εξωτερικού γινόμενου είναι τρία επί δύο.

```julia
function Oops!()
  vectorColumn = 8 -1
end
Oops!()
```

Σε αυτήν την περίπτωση, σύμφωνα με τα προηγούμενα, μπορεί να περιμέναμε κάποιο συντακτικό σφάλμα. Ωστόσο, στη δεξιά έκφραση, τα κενά, δεν έχουν σημασία, αντίθετα με την έκφραση αρχικοποίησης διανύσματος (πριν), όπου το κενό αντιπροσωπεύει το επόμενο στοιχείο στην γραμμή του διανύσματος. Συνεπώς, εδώ θα κληθεί ο δυαδικός τελεστής "-", μιας και εκτός του ορισμού μητρώων, τα κενά δεν έχουν σημασία.

```julia
function NotJustLiterals()
  vector1 = [2 -sqrt(2)]
  vector2 = [2 - sqrt(2)]
end
NotJustLiterals()
```

Εδώ, παρατηρούμε ότι το κενό (επόμενο στοιχείο πίνακα) έχει προτεραίοτητα της αφαίρεσης, ανεξαρτήτως αν πρόκειται για literal ή αποτέλεσμα συνάρτησης. Το vector1 θα έχει δύο στοιχεία, ενώ το vector2 θα έχει μόνο ένα, μιας και εκτελείται αφαίρεση.



# Πειραματικά Αποτελέσματα

## Τεχνικά Χαρακτηριστικά Συστήματος

Για τις μετρήσεις χρησιμοποιήθηκε το ακόλουθο σύστημα:

|Λογισμικό||
|---|---|
|Operating System| Linux Ubuntu|
|Version| 16.0.4|
|Kernel| 4.17.11|
|Julia|0.6.4|
|PAPI|5.6.0|

---------------

|Υλικό||
|---|---|
|CPU| Intel i7 2600K|
|Πυρήνες|4|
|Νήματα|8|
|Συχνότητα| 3.4GHz (Turbo Boost enabled)|
|Instruction Sets| SSE4.2, AVX|
|L1 Data Cache| 8 way 32KB|
|L1 Instruction Cache| 8 way 32KB|
|L2 Cache| 8 way 256KB|
|L3 Cache| 16 way 8MB|
|Cache line|64 Bytes|
|RAM|12GB DDR3|
|Συχνότητα RAM| 1600MHz|

## Στόχος πειράματος

Η πειραματική μέθοδος που ακολουθήθηκε, αποσκοπεί στη συγκέντρωση δεδομένων επίδοσης του επεξεργαστή, ώστε να παρουσιαστεί η δυνατότητα της χρήσης αυτής της μεθόδου ως benchmark.

Ο κύριος σκοπός είναι να συγκριθεί η συγκεκριμένη μέθοδος, με υπάρχουσες μεθόδους benchmarking που χρησιμοποιούν διαφορετικούς αλγορίθμους. Θα παρουσιαστούν τα πλεονεκτήματα και μειονεκτήματα αυτής της μεθόδου, σε σχέση με τις υπάρχουσες, και θα αναλυθεί η καταλληλόλητά της ως ένα αντικειμενικότερο κριτήριο επίδοσης.

Επιπροσθέτως, είναι θεμιτή η ανάλυση της συμπεριφοράς του συστήματος, σχετικά με τα διαφορετικά είδη και μεγέθη μητρώων. Συνεπώς, θα παρουσιαστεί μια συγκριτική ανάλυση επιδόσεων, αναλογικά με το είδος του μητρώου, το μέγεθός του, καθώς και το πόσο πυκνό είναι (το ποσοστό μη μηδενικών στοιχείων του).

Ένας ακόμη στόχος, είναι η μελέτη της αύξησης των επιδόσεων με την εκμετάλλευση παραλληλίας. Η παραλληλία είναι ένα βασικό χαρακτηριστικό της προόδου των σύγχρονων επεξεργαστών, συνεπώς είναι κρίσιμο το να συμπεριληφθεί σε ένα benchmark επιδόσεων. Όπως θα αναλυθεί, το πρόβλημα το οποίο θα χρησιμοποιήσουμε για το πείραμα, προσφέρεται για παραλληλία. Τέλος, έχει αξία να συγκριθούν διαφορετικές υλοποιήσεις παραλληλίας.

## Διαδικασία μετρήσεων

Για τη λήψη των μετρήσεων, ακολουθήθηκε η εξής μέθοδος, όπως θα επαληθευθεί στον κώδικα που ακολουθεί:

1. Ορίστηκαν και φορτώθηκαν στη RAM όλα τα μητρώα που θα χρειαστούν στις μετρήσεις.
2. Εκκινήθηκαν οι απαραίτητοι μετρητές πράξεων της βιβλιοθήκης PAPI.
3. Ο κώδικας προς μέτρηση, εκτελέστηκε μία φορά ώστε να προθερμανθούν όλα τα σχετικά υποσυστήματα σε επίπεδο λογισμικού και υλικού (μεταγλώττιση των συναρτήσεων και cache αντίστοιχα)
4. Εκτελέστηκε η μέτρηση των πράξεων, με δέκα επαναλήψεις
5. Έπειτα, για δέκα άλλες επαναλήψεις χρονομετρήθηκε η διάρκεια ολοκλήρωσής τους
6. Οι χρόνοι αυτοί καταγράφηκαν, και υπολογίστηκε ο μέσος όρος τους.
7. Από τους δύο αυτούς μέσους όρους (πλήθος πράξεων και χρόνου εκτέλεσης), παράχθηκε ο αριθμός των FLOP/s.

### Αιτιολόγηση

Ο κύριος στόχος ήταν η ελαχιστοποίηση των εξωτερικών παραγόντων που μπορεί να επηρεάσουν τις μετρήσεις. Γι' αυτό το λόγο,  περιορίστηκαν / τερματίστηκαν, στο μέγιστο δυνατόν, όλες οι υπόλοιπες διεργασίες στο σύστημα. Επιπλέον, όλα τα δεδομένα που θα χρειάζονταν για τις μετρήσεις, φορτώθηκαν στην κύρια μνήμη εκ των προτέρων.

Ο κώδικας Julia είναι JIT (Just In Time) compiled, δηλαδή μεταγλωττίζεται τη στιγμή που χρειάζεται να εκτελεστεί. Επειδή η κλήση και εκτέλεση του μεταγλωττιστή αποτελεί μεγάλο κόστος, το οποίο δεν συσχετίζεται με τη μέτρηση εκτέλεσης, αλλά την ίδια τη γλώσσα, φροντίζουμε να μεταγλωττίσουμε τον κώδικα προς εξέταση πριν τη διαδικασία μέτρησης. Αυτό επιτυγχάνεται, κάνοντας χρήση τόσο της συνάρτησης `precompile()` της Julia, καθώς και με το να κληθεί κανονικά η συνάρτηση που θέλουμε να μετρήσουμε, με τα κανονικά της ορίσματα, απλά χωρίς να μετρήσουμε τίποτα σχετικό με την εκτέλεση αυτή. Αυτή η διαδικασία, είναι συνήθως γνωστή ως **warmup** (προθέρμανση) στη βιβλιογραφία της μέτρησης απόδοσης.

Ένα συνακόλουθο της κλήσης της συνάρτησης πριν χρονομετρηθεί, είναι πως είναι εξαιρετικά πιθανό, να βρίσκονται σε κάποιο επίπεδο της cache τα δεδομένα που θα χρειαστούν στον υπολογισμό. Τα προαναφερθέντα, προϋποθέτουν ότι το μητρώο/τα δεδομένα μας, χωράνε εξ ολοκλήρου στην κρυφή μνήμη. Σε περίπτωση που είναι μεγαλύτερα από το μέγιστο επίπεδο κρυφής, το τελευταίο τμήμα των δεδομένων θα γραφτεί στη θέση του πρώτου, άρα κατά τη διάρκεια των μετρήσεων ξεκινάμε με άδεια cache (από χρήσιμα δεδομένα). Επιπροσθέτως, το υποσύστημα branch prediction (πρόβλεψης διακλάδωσης) της κεντρικής μονάδας επεξεργασίας, μιας και έχει συναντήσει τον κώδικα που πρόκειται να εκτελεστεί, έχει ορθά  προετοιμάσει τον αλγόριθμο που θα χρησιμοποιήσει για την πρόβλεψη. Όλα αυτά, δημιουργούν τις πλέον ιδανικές συνθήκες μέτρησης χρόνου εκτέλεσης, κάτι το οποίο είναι θεμιτό ώστε να αντιπροσωπεύει μετρήσεις στις οποίες ο χρόνος εκτέλεσής τους, είναι τάξης μεγέθους μεγαλύτερος από αυτόν της αρχικοποίησης και των σταθερών ( Ο(1) ) διαδικασιών.

## Δεδομένα

Τα μητρώα που θα χρησιμοποιηθούν στα πειράματα, προέρχονται από τη Suite Sparse συλλογή μητρώων (γνωστή και ως συλλογή αραιών μητρώων του πανεπιστημίου της Florida). Για τη διεπαφή με τον ιστότοπο της Suite Sparse, χρησιμοποιήθηκε το πακέτο MatrixDepot της Julia, το οποίο επιτρέπει το κατέβασμα και χρήση στη Julia οποιουδήποτε μητρώου στην βιβλιοθήκη. Η χρήση αυτού του πακέτου δεν είναι απαραίτητη, μιας και τα μητρώα παρέχονται στην ιστοσελίδα και σε μορφή `.mat` συμβατή τόσο με Matlab όσο και με Julia, ωστόσο είναι ευκολότερο να εκμεταλλευτούμε αυτή τη διεπαφή.


Τα μητρώα που θα χρησιμοποιηθούν για μετρήσεις, θα είναι όλα συμμετρικά θετικά ορισμένα (Symmmetric Positive Definite). Τα χαρακτηριστικά τα οποία θέλουμε να μελετήσουμε ως μεταβλητές είναι τα ακόλουθα:

* Το μέγεθος του μητρώου, με κατηγορίες μικρά, μεσαία και μεγάλα μητρώα, που εξαρτάται απ' το μέγεθος των διαστάσεων του μητρώου.
* Η πυκνότητα του μητρώου, δηλαδή η αναλογία των μη μηδενικών στοιχείων, προς το σύνολο των στοιχείων του μητρώου
* Η συμμετρία των στοιχείων, μιας και μπορούμε να εξετάσουμε ψευδο-συμμετρικά μητρώα, δηλαδή αυτά που οι τιμές τους δεν είναι συμμετρικές, αλλά είναι πολύ κοντά σε συμμετρικές


Τα μητρώα που επιλέχθηκαν είναι τα ακόλουθα:

<!-- |Όνομα|Μέγεθος|Μη Μηδενικά Στοιχεία|rank|URL|
|---|---|---|---|---|
|bcsstk01|48x48|400|48|https://sparse.tamu.edu/HB/bcsstk01|
|bcsstk02|66x66|4356|66|https://sparse.tamu.edu/HB/bcsstk02|
|bcsstk03|112x112|640|112|https://sparse.tamu.edu/HB/bcsstk03|
|Trefethen_20b|19x19|147|19|https://sparse.tamu.edu/JGD_Trefethen/Trefethen_20b|
|Journals|124x124|12068|124|https://sparse.tamu.edu/Pajek/Journals| -->

|Όνομα|Μέγεθος|Μη Μηδενικά Στοιχεία|URL|
|---|---|---|---|---|
|smt|25,710x25,710|3,749,582|https://sparse.tamu.edu/TKK/smt|
|fv3|	9,801x	9,801|87,025|https://sparse.tamu.edu/Norris/fv3|
|nd3k|9,000x9,000|3,279,690|https://sparse.tamu.edu/ND/nd3k|


