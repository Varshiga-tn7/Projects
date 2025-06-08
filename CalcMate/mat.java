public class mat {
    public static void main(String[] args) {
       int arr[][]= { {1,2,3}, {4,5,6}, {7,8,9}}
           int a = 0;
           int b = 0;
           int n = arr.length;
       for (int i=0; i< n ; i++){
        for (int j=0; j< n ; j++){
            if(i==j)
            { a+= arr[i][j];  }

            for (int j= n-1 ; j< 0 ; j--){
                if(i==j)
                { a+= arr[i][j];  }    
       }


    }
    
    
}
}
