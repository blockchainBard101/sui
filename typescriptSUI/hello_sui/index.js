var indon = /** @class */ (function () {
    function indon(n, a) {
        this.name = n;
        this.age = a;
        console.log("Hello Sui");
    }
    return indon;
}());
var ind = new indon("George", 19);
console.log(ind.name);
