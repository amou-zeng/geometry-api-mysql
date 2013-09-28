概述
================
	玩过微信的童鞋对“附近的人”这个功能并不陌生，“附近的人”使用GPS全球定位系统，通过对比地理位置坐标Geometry（也即是经纬度），计算出与自己距离最近的人。
	本项目使用Mysql作为存储引擎，通过存储过程（Procedure）来计算并获取“附近的人”。

这是什么？
----------------
	本项目由一组SQL语句组成，其中包含数据表、函数、存储过程各一个。
	
*	数据表`geo_data`包含三个字段，uid代表用户标识，可以是用户名／用户Id，还有两个字段是经纬度。
*	函数`geoDistanceBetween`返回两个地理位置的距离，单位是米(meters)。
*	存储过程`geoNeighbourhood`返回两个

使用方法
----------------
### 导入语句
	source geometry-api-mysql.sql

### 获取附近的人
	call geoNeighbourhood(1, 100, 30);
	-- 这样就可以获得用户标示等于1，100米内的附近30个用户了