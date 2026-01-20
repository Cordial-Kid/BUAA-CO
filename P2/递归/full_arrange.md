# 全排列代码

``` c
// first to confirm indexth position
void FullArray(int index){
    if(index >= n){
        for(int i=0; i<n; i++) printf("%d ", array[i]);
        printf("\n");
        return;
    }
    //the number can vary from 1-n
    for(int i=0; i<n; i++){
        if(symbol[i]==0){
            array[index] = i+1;
            symbol[i] = 1;
            FullArray(index+1);
            symbol[i] = 0;
        }
    }
}
```
